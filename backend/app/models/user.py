import uuid
import enum
from datetime import datetime
from sqlalchemy import Column, String, Boolean, DateTime, Enum, TypeDecorator
import sqlalchemy.types as types

class UUIDType(TypeDecorator):
    """Platform-independent UUID type. Uses String(36) for SQLite."""
    impl = types.String
    cache_ok = True

    def __init__(self):
        super().__init__(length=36)

    def process_bind_param(self, value, dialect):
        if value is not None:
            return str(value)
        return value

    def process_result_value(self, value, dialect):
        if value is not None:
            return uuid.UUID(value) if not isinstance(value, uuid.UUID) else value
        return value
from sqlalchemy.orm import declarative_base, relationship
import sqlalchemy.orm
from sqlalchemy import ForeignKey, Integer

from app.core.database import Base

class UserType(str, enum.Enum):
    elderly = "elderly"
    family = "family"
    guardian = "guardian"
    admin = "admin"

class User(Base):
    __tablename__ = "users"

    id = Column(UUIDType(), primary_key=True, default=uuid.uuid4)
    phone = Column(String(15), unique=True, index=True, nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=True)
    name = Column(String(100), nullable=False)
    
    # Nullable for OTP-based authentication strategies
    hashed_password = Column(String(255), nullable=True)
    
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    user_type = Column(Enum(UserType), default=UserType.elderly, index=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login = Column(DateTime, nullable=True)

    # Relationships mapped dynamically via strings without tight coupling
    emergency_contacts = relationship("EmergencyContact", back_populates="user", cascade="all, delete-orphan")
    medications = relationship("Medication", back_populates="user", cascade="all, delete-orphan")
    guardian_profile = relationship("GuardianProfile", uselist=False, back_populates="user")
    alerts = relationship("Alert", back_populates="user")

    def __repr__(self):
        return f"<User(id={self.id}, name='{self.name}', phone='{self.phone}', type='{self.user_type}')>"

    def to_dict(self):
        return {
            "id": str(self.id),
            "phone": self.phone,
            "email": self.email,
            "name": self.name,
            "is_active": self.is_active,
            "is_verified": self.is_verified,
            "user_type": self.user_type.value if hasattr(self.user_type, "value") else self.user_type,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "last_login": self.last_login.isoformat() if self.last_login else None,
        }

class EmergencyContact(Base):
    __tablename__ = "emergency_contacts"
    id = Column(UUIDType(), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUIDType(), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    name = Column(String, nullable=False)
    phone = Column(String, nullable=False)
    relationship = Column(String, nullable=False)
    priority = Column(Integer, default=1)
    is_verified = Column(Boolean, default=False)
    
    user = sqlalchemy.orm.relationship("User", back_populates="emergency_contacts")

class GuardianProfile(Base):
    __tablename__ = "guardian_profiles"
    id = Column(UUIDType(), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUIDType(), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True)
    
    user = relationship("User", back_populates="guardian_profile")

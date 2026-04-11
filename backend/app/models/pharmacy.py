import uuid
from datetime import datetime
from sqlalchemy import Column, String, Float, Boolean, DateTime, Date, ForeignKey, JSON, Text, Index
from app.models.user import UUIDType
from sqlalchemy.orm import declarative_base, relationship

from app.core.database import Base

class Pharmacy(Base):
    __tablename__ = "pharmacies"

    id = Column(UUIDType(), primary_key=True, default=uuid.uuid4)
    name = Column(String(200), nullable=False)
    address = Column(Text, nullable=False)
    phone = Column(String(15), nullable=True)
    email = Column(String(255), nullable=True)
    
    location_lat = Column(Float, nullable=False, index=True)
    location_lng = Column(Float, nullable=False, index=True)
    
    is_verified = Column(Boolean, default=False)
    is_partner = Column(Boolean, default=False)
    
    operating_hours = Column(JSON, nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    availabilities = relationship("MedicineAvailability", back_populates="pharmacy", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Pharmacy(id={self.id}, name='{self.name}', is_verified={self.is_verified})>"

class MedicineAvailability(Base):
    __tablename__ = "medicine_availability"

    id = Column(UUIDType(), primary_key=True, default=uuid.uuid4)
    pharmacy_id = Column(UUIDType(), ForeignKey("pharmacies.id", ondelete="CASCADE"), index=True, nullable=False)
    
    medicine_name = Column(String(100), nullable=False, index=True)
    generic_name = Column(String(100), nullable=True)
    
    is_available = Column(Boolean, nullable=False)
    quantity = Column(String(50), nullable=True)  # e.g., "10 strips"
    expiry_date = Column(Date, nullable=True)
    price = Column(Float, nullable=True)
    
    verified_by = Column(UUIDType(), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    verified_at = Column(DateTime, default=datetime.utcnow)
    confidence_score = Column(Float, default=0.0)  # Scoring metric: 0.0 - 100.0
    notes = Column(Text, nullable=True)

    # Relationships
    pharmacy = relationship("Pharmacy", back_populates="availabilities")
    # Link backwards to whoever verified it
    verifier = relationship("User")

    # Configured Composite Indexes
    __table_args__ = (
        Index("idx_pharmacy_medicine", "pharmacy_id", "medicine_name"),
        Index("idx_medicine_available", "medicine_name", "is_available"),
    )

    def __repr__(self):
        return f"<MedicineAvailability(id={self.id}, medicine='{self.medicine_name}', is_available={self.is_available})>"

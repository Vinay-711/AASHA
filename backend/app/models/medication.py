import uuid
import enum
from datetime import datetime
from sqlalchemy import Column, String, DateTime, Date, ForeignKey, JSON, Text, Enum
from app.models.user import UUIDType
from sqlalchemy.orm import declarative_base, relationship

from app.core.database import Base

class LogStatus(str, enum.Enum):
    taken = "taken"
    missed = "missed"
    skipped = "skipped"

class Medication(Base):
    __tablename__ = "medications"

    id = Column(UUIDType(), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUIDType(), ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    
    name = Column(String(100), nullable=False)
    generic_name = Column(String(100), nullable=True)
    dosage = Column(String(50), nullable=False)  # e.g., "25mg"
    frequency = Column(String(50), nullable=False)  # e.g., "twice daily"
    timing = Column(JSON, nullable=False)  # e.g., [{"time": "08:00", "with_food": true}]
    
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=True)
    instructions = Column(Text, nullable=True)
    color_code = Column(String(7), nullable=True)  # Hex color for AR
    shape = Column(String(20), nullable=True)  # "round", "oval", etc.
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    # Note: 'User' must define medications = relationship("Medication", back_populates="user")
    user = relationship("User", back_populates="medications")
    logs = relationship("MedicationLog", back_populates="medication", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Medication(id={self.id}, name='{self.name}', dosage='{self.dosage}')>"


class MedicationLog(Base):
    __tablename__ = "medication_logs"

    id = Column(UUIDType(), primary_key=True, default=uuid.uuid4)
    medication_id = Column(UUIDType(), ForeignKey("medications.id", ondelete="CASCADE"), index=True, nullable=False)
    user_id = Column(UUIDType(), ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    
    taken_at = Column(DateTime, nullable=False)
    scheduled_for = Column(DateTime, nullable=False)
    status = Column(Enum(LogStatus), nullable=False)
    location = Column(JSON, nullable=True)  # e.g., {"lat": x, "lng": y}
    notes = Column(Text, nullable=True)

    # Relationships
    user = relationship("User") # No back_populates array specified originally, so implicit one-way is fine
    medication = relationship("Medication", back_populates="logs")

    def __repr__(self):
        return f"<MedicationLog(id={self.id}, status='{self.status}')>"

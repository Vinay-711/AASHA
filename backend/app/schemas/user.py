from pydantic import BaseModel, ConfigDict, Field, EmailStr
from typing import Optional, Literal
from datetime import datetime
from uuid import UUID

# ---------------------------------------------------------
# User Schemas
# ---------------------------------------------------------

class UserBase(BaseModel):
    # Loosened restrictions for local demo login via email inputs
    phone: str = Field(description="Phone or email identifier")
    email: Optional[EmailStr] = None
    name: str = Field(min_length=2, max_length=100)

class UserCreate(UserBase):
    password: Optional[str] = Field(default=None, min_length=8)
    user_type: Literal["elderly", "family", "guardian"] = "family"

class UserResponse(UserBase):
    id: UUID
    is_verified: bool
    user_type: str
    created_at: datetime
    
    # Enables ORM resolution directly from SQLAlchemy objects
    model_config = ConfigDict(from_attributes=True)

class UserLogin(BaseModel):
    phone: str
    otp: str = Field(min_length=6, max_length=6)


# ---------------------------------------------------------
# Emergency Contact Schemas
# ---------------------------------------------------------

class EmergencyContactCreate(BaseModel):
    name: str
    phone: str
    relationship: str
    priority: int = Field(ge=1, le=5)

class EmergencyContactResponse(EmergencyContactCreate):
    id: UUID
    is_verified: bool
    
    # Enables ORM resolution directly from SQLAlchemy objects
    model_config = ConfigDict(from_attributes=True)

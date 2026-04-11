from pydantic import BaseModel, Field
from typing import Optional, Literal, List, Dict, Any
from datetime import datetime
from uuid import UUID

# ---------------------------------------------------------
# Augmented Reality (AR) Schemas
# ---------------------------------------------------------

class ARScanRequest(BaseModel):
    # Note: 'image: UploadFile' is handled directly in the FastAPI endpoint signature
    # because multipart/form-data with file payloads doesn't map directly into JSON Pydantic models.
    
    location: Optional[Dict[str, Any]] = Field(
        default=None, 
        json_schema_extra={"example": {"lat": 28.61, "lng": 77.20}}
    )
    timestamp: Optional[datetime] = Field(default_factory=datetime.utcnow)

class AROverlay(BaseModel):
    # Regex explicitly validates standard hex color codes
    color: str = Field(pattern=r"^#[0-9A-Fa-f]{6}$")
    position: Dict[str, Any] = Field(json_schema_extra={"example": {"x": 120, "y": 200, "z": 0}})
    size: Dict[str, Any] = Field(json_schema_extra={"example": {"width": 80, "height": 40}})
    animation: Literal["pulse", "static", "glow"]

class DetectedMedicine(BaseModel):
    id: str
    name: str
    generic_name: Optional[str] = None
    confidence: float = Field(ge=0.0, le=1.0)
    status: Literal["take_now", "wait", "taken", "not_today", "warning"]
    dosage: str
    schedule: Dict[str, Any] = Field(
        json_schema_extra={"example": {"today_taken": 1, "today_total": 2, "next_dose": "2026-04-10T20:00:00Z"}}
    )
    ar_overlay: AROverlay
    warnings: List[str] = Field(default_factory=list)
    interactions: List[str] = Field(default_factory=list)

class ARScanResponse(BaseModel):
    scan_id: UUID
    processing_time_ms: int
    medicines: List[DetectedMedicine]
    unrecognized_pills: int
    confidence_threshold_met: bool
    suggestions: Optional[List[str]] = None

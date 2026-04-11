import uuid
from datetime import datetime
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status, Path
from pydantic import BaseModel
from sqlalchemy.orm import Session


# Dummy dependencies (match pharmacy.py pattern for now)
def get_db():
    yield None


def get_current_user():
    return {"id": "123", "name": "Test User", "user_type": "elderly"}


router = APIRouter()


# ── Schemas ──────────────────────────────────────────────────────────────────


class TimingEntry(BaseModel):
    time: str  # e.g. "08:00"
    with_food: bool = False


class CreateMedicationRequest(BaseModel):
    name: str
    generic_name: Optional[str] = None
    dosage: str
    frequency: str
    timing: List[TimingEntry]
    start_date: str  # ISO date
    end_date: Optional[str] = None
    instructions: Optional[str] = None
    color_code: Optional[str] = None
    shape: Optional[str] = None


class MedicationResponse(BaseModel):
    id: str
    name: str
    generic_name: Optional[str]
    dosage: str
    frequency: str
    timing: list
    start_date: str
    end_date: Optional[str]
    instructions: Optional[str]
    color_code: Optional[str]
    shape: Optional[str]
    created_at: Optional[str]


class LogAdherenceRequest(BaseModel):
    status: str  # "taken", "missed", "skipped"
    scheduled_for: str  # ISO datetime
    notes: Optional[str] = None


class MedicationLogResponse(BaseModel):
    id: str
    medication_id: str
    status: str
    taken_at: str
    scheduled_for: str
    notes: Optional[str]


# ── Mock Storage (until real DB session wired) ───────────────────────────────

MOCK_MEDICATIONS = [
    {
        "id": "med_001",
        "name": "Cardivas 25mg",
        "generic_name": "Carvedilol",
        "dosage": "25mg",
        "frequency": "twice daily",
        "timing": [
            {"time": "08:00", "with_food": True},
            {"time": "20:00", "with_food": True},
        ],
        "start_date": "2026-01-15",
        "end_date": None,
        "instructions": "Take with meals. Do not stop abruptly.",
        "color_code": "#4CAF50",
        "shape": "round",
        "created_at": "2026-01-15T10:00:00",
    },
    {
        "id": "med_002",
        "name": "Paracetamol 500mg",
        "generic_name": "Acetaminophen",
        "dosage": "500mg",
        "frequency": "as needed",
        "timing": [{"time": "08:00", "with_food": False}],
        "start_date": "2026-03-01",
        "end_date": "2026-06-01",
        "instructions": "Take for fever or pain. Max 4 doses per day.",
        "color_code": "#2196F3",
        "shape": "oval",
        "created_at": "2026-03-01T09:00:00",
    },
]

MOCK_LOGS: list = []


# ── Endpoints ────────────────────────────────────────────────────────────────


@router.get("/", response_model=List[MedicationResponse])
async def list_medications(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    """List all medications for the current user."""
    return MOCK_MEDICATIONS


@router.post(
    "/", response_model=MedicationResponse, status_code=status.HTTP_201_CREATED
)
async def create_medication(
    request: CreateMedicationRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    """Add a new medication for the current user."""
    new_med = {
        "id": f"med_{uuid.uuid4().hex[:8]}",
        "name": request.name,
        "generic_name": request.generic_name,
        "dosage": request.dosage,
        "frequency": request.frequency,
        "timing": [t.dict() for t in request.timing],
        "start_date": request.start_date,
        "end_date": request.end_date,
        "instructions": request.instructions,
        "color_code": request.color_code,
        "shape": request.shape,
        "created_at": datetime.utcnow().isoformat(),
    }
    MOCK_MEDICATIONS.append(new_med)
    return new_med


@router.post(
    "/{medication_id}/log",
    response_model=MedicationLogResponse,
    status_code=status.HTTP_201_CREATED,
)
async def log_adherence(
    request: LogAdherenceRequest,
    medication_id: str = Path(...),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    """Log an adherence event (taken/missed/skipped) for a medication."""
    if request.status not in ("taken", "missed", "skipped"):
        raise HTTPException(
            status_code=400, detail="Status must be taken, missed, or skipped"
        )

    log_entry = {
        "id": f"log_{uuid.uuid4().hex[:8]}",
        "medication_id": medication_id,
        "status": request.status,
        "taken_at": datetime.utcnow().isoformat(),
        "scheduled_for": request.scheduled_for,
        "notes": request.notes,
    }
    MOCK_LOGS.append(log_entry)
    return log_entry


@router.get("/{medication_id}/logs", response_model=List[MedicationLogResponse])
async def get_medication_logs(
    medication_id: str = Path(...),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    """Get adherence log history for a specific medication."""
    return [log for log in MOCK_LOGS if log["medication_id"] == medication_id]

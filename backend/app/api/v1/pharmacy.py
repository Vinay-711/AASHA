import math
from datetime import datetime, timedelta
from typing import List, Optional, Dict, Any
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Path, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import func

# ---------------------------------------------------------
# Dummy Dependencies (Replace with actual injections when wiring logic)
# ---------------------------------------------------------
def get_db():
    yield None

def get_current_user():
    return {"id": "123", "name": "Test User", "user_type": "elderly"}

router = APIRouter()

# ---------------------------------------------------------
# Pydantic Schemas (Locally maintained for independent scale)
# ---------------------------------------------------------
class PharmacyResponse(BaseModel):
    id: str
    name: str
    distance_km: float
    availability: Dict[str, Any]

class PharmacySearchResponse(BaseModel):
    pharmacies: List[PharmacyResponse]
    cached: bool = False

class VerifyAvailabilityRequest(BaseModel):
    pharmacy_id: str
    medicine_name: str
    is_available: bool
    quantity: Optional[str] = None

class ExtendedPharmacyResponse(BaseModel):
    id: str
    name: str
    address: str
    phone: Optional[str]
    medicines: List[Dict[str, Any]]

# ---------------------------------------------------------
# Caching State
# ---------------------------------------------------------
SEARCH_CACHE = {}
CACHE_TTL = timedelta(minutes=5)

# ---------------------------------------------------------
# Utilities
# ---------------------------------------------------------
def calculate_haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate the great circle distance between two points on the earth."""
    R = 6371.0 # Earth radius in kilometers
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

# ---------------------------------------------------------
# Endpoints
# ---------------------------------------------------------

@router.get("/search", response_model=PharmacySearchResponse)
async def search_pharmacy(
    medicine_name: str = Query(..., description="Medicine to search for"),
    lat: float = Query(..., description="Current latitude. Must be between -90 and 90", ge=-90, le=90),
    lng: float = Query(..., description="Current longitude. Must be between -180 and 180", ge=-180, le=180),
    radius_km: float = Query(5.0, description="Search radius limit in km"),
    in_stock_only: bool = Query(False, description="Filter completely out of stock items"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Search for medicine availability in nearby pharmacies.
    Implemented with a 5-minute caching layer and haversine sorting.
    If PostGIS is available, standard filtering occurs optimally at the SQL level.
    """
    cache_key = f"{medicine_name.lower()}_{lat:.3f}_{lng:.3f}_{radius_km}_{in_stock_only}"
    
    # 1. Evaluate Cache Layer (5 minutes TTL)
    if cache_key in SEARCH_CACHE:
        cached_data, timestamp = SEARCH_CACHE[cache_key]
        if datetime.utcnow() - timestamp < CACHE_TTL:
            return PharmacySearchResponse(pharmacies=cached_data, cached=True)

    # 2. Database Geolocation & Query Execution (Mocked arrays scaling Haversine locally for MVP)
    # Ideally: queries pharmacy and calculates PostGIS ST_Distance -> mapping fallback to Haversine
    mock_results = [
        PharmacyResponse(id="pharm_001", name="Apollo Pharmacy", distance_km=calculate_haversine(lat, lng, lat+0.01, lng+0.01), availability={"status": "in_stock", "confidence": 95, "verified_by": "Ram S."}),
        PharmacyResponse(id="pharm_002", name="MedPlus", distance_km=calculate_haversine(lat, lng, lat+0.03, lng-0.02), availability={"status": "out_of_stock", "confidence": 80, "verified_by": "Priya M."}),
        PharmacyResponse(id="pharm_003", name="Local Chemist", distance_km=calculate_haversine(lat, lng, lat-0.02, lng+0.04), availability={"status": "limited_stock", "confidence": 65, "verified_by": "Guardian Raj"})
    ]

    # Validate distance boundaries dynamically
    valid_results = [res for res in mock_results if res.distance_km <= radius_km]
    
    if in_stock_only:
        valid_results = [res for res in valid_results if res.availability.get("status") in ("in_stock", "limited_stock")]

    # Sort results heavily penalizing out-of-stock items, then by physical Haversine distance
    valid_results.sort(key=lambda x: (x.availability.get("status") != "in_stock", x.distance_km))

    # 3. Log into Memory Cache & Dispatch Response
    SEARCH_CACHE[cache_key] = (valid_results, datetime.utcnow())
    
    return PharmacySearchResponse(pharmacies=valid_results, cached=False)


@router.post("/verify")
async def verify_availability(
    request: VerifyAvailabilityRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Verify medicine availability at a pharmacy to build the crowdsourced network.
    Awards user points based on verification and triggers local caching invalidations.
    """
    # 1. Authorization Permission Checks
    if not current_user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Must be authenticated to verify medicine.")
    
    # 2. Add or Update MedicineAvailability SQL record & compute confidence score dynamically
    # Guardian profiles inherently carry higher confidence mapping thresholds natively
    new_confidence = 90.0 if current_user.get("user_type") == "guardian" else 65.0
    
    # 3. Calculate gamified points and badge hooks
    points_awarded = 15
    new_badge = None
    
    # Mock threshold for demonstration
    total_lifetime_points = 120 
    if total_lifetime_points > 100:  
        new_badge = "Community Healer"
        
    # 4. Cache Invalidation Engine (Clear regional caches holding this medicine)
    keys_to_clear = [k for k in SEARCH_CACHE.keys() if request.medicine_name.lower() in k]
    for k in keys_to_clear:
        del SEARCH_CACHE[k]

    return {
        "success": True,
        "points_earned": points_awarded,
        "new_badge": new_badge,
        "confidence_updated": new_confidence
    }


@router.get("/nearby", response_model=List[Dict[str, Any]])
async def get_nearby_pharmacies(
    lat: float = Query(...),
    lng: float = Query(...),
    radius_km: float = Query(5.0),
    db: Session = Depends(get_db),
    
    # Optional Auth implicitly supported mapping to None if Token absent
    current_user: Optional[dict] = Depends(lambda: None) 
):
    """
    Get all pharmacies physically near a targeted spatial location irrespective of stock APIs.
    Scales natively against Haversine (with scalable PostGIS implementations down the line).
    """
    return [
        {"id": "pharm_001", "name": "Apollo Pharmacy", "distance_km": round(calculate_haversine(lat, lng, lat+0.01, lng+0.01), 2)},
        {"id": "pharm_002", "name": "MedPlus", "distance_km": round(calculate_haversine(lat, lng, lat+0.03, lng-0.02), 2)}
    ]


@router.get("/{pharmacy_id}", response_model=ExtendedPharmacyResponse)
async def get_pharmacy_details(
    pharmacy_id: str = Path(...),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Fetch completely extended entity profiles and all currently logged MedicineAvailability 
    metrics structurally bound to a targeted Pharmacy.
    """
    return ExtendedPharmacyResponse(
        id=pharmacy_id,
        name="Apollo Pharmacy",
        address="123 Health Ave, New Delhi",
        phone="+919876543210",
        medicines=[
            {"name": "Cardivas 25mg", "is_available": True, "confidence": 95},
            {"name": "Paracetamol 500mg", "is_available": True, "confidence": 99}
        ]
    )

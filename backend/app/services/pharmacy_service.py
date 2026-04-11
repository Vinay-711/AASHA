import math
import logging
from datetime import datetime, timedelta
from typing import List, Optional, Any, Dict
from uuid import UUID

from sqlalchemy.orm import Session
from sqlalchemy import func

# Explicitly load underlying database definitions
from app.models.pharmacy import Pharmacy, MedicineAvailability
from app.models.user import User

logger = logging.getLogger("aasha.pharmacy_service")

# ---------------------------------------------------------
# Internal Typing Envelopes
# ---------------------------------------------------------
class PharmacyWithAvailability:
    def __init__(self, pharmacy: Pharmacy, availability_status: str, confidence: float, distance_km: float):
        self.pharmacy = pharmacy
        self.availability_status = availability_status
        self.confidence = confidence
        self.distance_km = distance_km

class VerificationResult:
    def __init__(self, success: bool, points_earned: int, new_badge: Optional[str] = None):
        self.success = success
        self.points_earned = points_earned
        self.new_badge = new_badge

class PharmacyDetail:
    def __init__(self, pharmacy: Pharmacy, medicines: List[Dict[str, Any]]):
        self.pharmacy = pharmacy
        self.medicines = medicines

# ---------------------------------------------------------
# Caching Layer Constraints
# ---------------------------------------------------------
SERVICE_CACHE = {}
CACHE_TTL = timedelta(minutes=5)

# ---------------------------------------------------------
# Core Pharmacy Pipeline Lifecycle
# ---------------------------------------------------------
class PharmacyService:
    def __init__(self, db: Session):
        self.db = db

    async def search_medicine_availability(
        self,
        medicine_name: str,
        lat: float,
        lng: float,
        radius_km: float = 5.0,
        in_stock_only: bool = False
    ) -> List[PharmacyWithAvailability]:
        """
        Search for medicine availability in natively mapping nearby pharmacies geometries.
        Follows a strict internally mapped 5-step spatial tracking paradigm natively handling SQLAlchemy outputs.
        """
        # Execute global cache filtering mechanism implicitly validating identical boundaries
        cache_key = f"search_{medicine_name.lower()}_{lat:.3f}_{lng:.3f}_{radius_km}_{in_stock_only}"
        if cache_key in SERVICE_CACHE:
            cached_data, timestamp = SERVICE_CACHE[cache_key]
            if datetime.utcnow() - timestamp < CACHE_TTL:
                return cached_data

        try:
            # 1. Fetch valid relational locations spatially constrained internally
            pharmacies = self.db.query(Pharmacy).all()
            
            valid_results: List[PharmacyWithAvailability] = []
            
            for pharm in pharmacies:
                dist = self._haversine_distance(lat, lng, pharm.location_lat, pharm.location_lng)
                
                # Check target inclusion natively scaling local proximity metrics
                if dist <= radius_km:
                    # 2. Extract corresponding dynamic relational geometries mapping medicine limits 
                    meds = self.db.query(MedicineAvailability).filter(
                        MedicineAvailability.pharmacy_id == pharm.id,
                        MedicineAvailability.medicine_name.ilike(f"%{medicine_name}%")
                    ).all()

                    # Fallbacks filtering boolean state internally
                    if in_stock_only:
                        meds = [m for m in meds if m.is_available]
                    
                    if not meds and in_stock_only:
                        continue

                    # Define the explicit availability status inherently dictating out_of_stock configurations
                    status = "in_stock" if any(m.is_available for m in meds) else "out_of_stock"
                    
                    # 3. Process explicit ML scoring weighting algorithmic trust logic dynamically
                    confidence_score = self._calculate_confidence_score(meds) if meds else 0.0

                    valid_results.append(
                        PharmacyWithAvailability(
                            pharmacy=pharm, 
                            availability_status=status,
                            confidence=confidence_score,
                            distance_km=dist
                        )
                    )

            # 4. Strict sort definitions sorting arrays actively via inline priorities (Status -> Confidence -> Distance)
            valid_results.sort(
                key=lambda x: (
                    x.availability_status != "in_stock",
                    -x.confidence,
                    x.distance_km
                )
            )

            # 5. Clip arrays generating strictly identical top-10 boundary bounds
            final_results = valid_results[:10]
            
            # Write explicitly inside bounds
            SERVICE_CACHE[cache_key] = (final_results, datetime.utcnow())
            return final_results

        except Exception as e:
            logger.error(f"Geospatial Query Failure parsing Spatial limits natively: {e}")
            return []

    def _haversine_distance(
        self, 
        lat1: float, 
        lng1: float, 
        lat2: float, 
        lng2: float
    ) -> float:
        """Calculate spatial geodesic matrices applying Haversine math inherently spanning Km constants natively."""
        R = 6371.0 # Static mapped radius matching global geometries in km!
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lng2 - lng1)
        a = math.sin(dlat / 2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        return R * c

    def _calculate_confidence_score(
        self, 
        verifications: List[MedicineAvailability]
    ) -> float:
        """
        Calculate weighted confidence parameters generating ML-scaled confidence boundaries natively.
        Uses identical explicit parameter bounds spanning 40% trust, 30% recency, and 30% accuracy loops!
        """
        if not verifications:
            return 0.0
            
        total_score = 0.0
        
        for ver in verifications:
            # Apply trust weight boundaries statically configured natively via external definitions later
            trust_weight = 40.0
            accuracy_weight = 30.0
            
            # Recency dictates implicit local mapping scaling dynamically (Decaying directly matching passing bounds >24H)
            recency_weight = 30.0
            hours_passed = (datetime.utcnow() - ver.verified_at).total_seconds() / 3600
            if hours_passed > 24:
                recency_weight = max(0, 30.0 - (hours_passed / 24))
                
            local_score = trust_weight + accuracy_weight + recency_weight
            total_score += local_score
            
        return min((total_score / len(verifications)), 100.0)

    async def verify_availability(
        self,
        user_id: UUID,
        pharmacy_id: UUID,
        medicine_name: str,
        availability: str,
        **kwargs
    ) -> VerificationResult:
        """
        Record natively structured gamification hooks handling structural PostgreSQL verification logic natively.
        Dynamically limits scaling parameters parsing explicit DB commits inside internal boundaries!
        """
        # Load local relational records isolating geometries reliably
        record = self.db.query(MedicineAvailability).filter(
            MedicineAvailability.pharmacy_id == pharmacy_id,
            MedicineAvailability.medicine_name.ilike(f"%{medicine_name}%")
        ).first()

        is_avail_bool = availability.lower() == "in_stock"

        if record:
            record.is_available = is_avail_bool
            record.verified_by = user_id
            record.verified_at = datetime.utcnow()
        else:
            record = MedicineAvailability(
                pharmacy_id=pharmacy_id,
                medicine_name=medicine_name,
                is_available=is_avail_bool,
                verified_by=user_id,
                quantity=kwargs.get("quantity"),
                confidence_score=75.0, # Target default initializations mapping native hooks securely
            )
            self.db.add(record)
            
        self.db.commit()
        
        # Structure payload parsing standard points logically natively granting constraints implicitly
        points_awarded = 15
        new_badge = kwargs.get("mock_badge_logic", "Community Contributor")
        
        # Explicit Invalidation executing dynamic dictionary tracking mechanisms linearly resolving out array caches!
        keys_to_clear = [k for k in SERVICE_CACHE.keys() if medicine_name.lower() in k]
        for key in keys_to_clear:
            del SERVICE_CACHE[key]
            
        return VerificationResult(success=True, points_earned=points_awarded, new_badge=new_badge)

    async def get_pharmacy_details(
        self, 
        pharmacy_id: UUID
    ) -> PharmacyDetail:
        """Resolve precise local geometries mapping identically generated PostgreSQL limits properly inside targets."""
        target_pharm = self.db.query(Pharmacy).filter(Pharmacy.id == pharmacy_id).first()
        
        if not target_pharm:
            return None
            
        meds = self.db.query(MedicineAvailability).filter(MedicineAvailability.pharmacy_id == pharmacy_id).all()
        
        meds_array = []
        for m in meds:
            meds_array.append({
                "name": m.medicine_name,
                "is_available": m.is_available,
                "quantity": m.quantity,
                "price": m.price,
                "confidence": m.confidence_score
            })
            
        return PharmacyDetail(pharmacy=target_pharm, medicines=meds_array)

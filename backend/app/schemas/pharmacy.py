from pydantic import BaseModel
from typing import List

class PharmacySearchRequest(BaseModel):
    query: str
    lat: float
    lng: float

class PharmacyResponse(BaseModel):
    pharmacies: List[str]

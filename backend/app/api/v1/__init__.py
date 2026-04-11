from fastapi import APIRouter
from app.api.v1 import auth, ar, pharmacy, users, health, safety, guardian

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(ar.router, prefix="/ar", tags=["ar"])
api_router.include_router(pharmacy.router, prefix="/pharmacy", tags=["pharmacy"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(health.router, prefix="/health", tags=["health"])
api_router.include_router(safety.router, prefix="/safety", tags=["safety"])
api_router.include_router(guardian.router, prefix="/guardian", tags=["guardian"])

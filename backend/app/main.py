import time
import logging
from collections import defaultdict
from typing import Callable, Awaitable

from fastapi import FastAPI, Request, Response, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from starlette.exceptions import HTTPException as StarletteHTTPException

# Import routers from the API v1 module
from app.api.v1 import auth, users, ar, pharmacy, health, safety, guardian, medications

# ---------------------------------------------------------
# Logging Configuration
# ---------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("aasha.api")

# ---------------------------------------------------------
# Application Initialization
# ---------------------------------------------------------
app = FastAPI(
    title="AASHA API",
    description="Backend AI-Assisted Safety & Health Assistant API Services",
    version="1.0.0",
)

# 1. CORS Middleware configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For mobile access, typically allow all or specific domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------
# Rate Limiting State (100 req / min per IP)
# ---------------------------------------------------------
class RateLimiter:
    def __init__(self, limit: int = 100, window: int = 60):
        self.limit = limit
        self.window = window
        self.history = defaultdict(list)

    def is_allowed(self, ip: str) -> bool:
        """Check if the provided IP has exceeded the configured limits."""
        now = time.time()
        # Filter history for the current window
        self.history[ip] = [t for t in self.history[ip] if now - t < self.window]
        
        if len(self.history[ip]) >= self.limit:
            return False
            
        self.history[ip].append(now)
        return True

limiter = RateLimiter()

# ---------------------------------------------------------
# 6. Request Logging & 7. Rate Limiting Middleware
# ---------------------------------------------------------
@app.middleware("http")
async def custom_middleware(request: Request, call_next: Callable[[Request], Awaitable[Response]]) -> Response:
    client_ip = request.client.host if request.client else "unknown"
    
    # Check rate limit
    if not limiter.is_allowed(client_ip):
        logger.warning(f"Rate limit exceeded (100 req/min) for IP: {client_ip}")
        return JSONResponse(
            status_code=429, 
            content={"detail": "Too Many Requests. Please wait a moment."}
        )

    # Log incoming request
    start_time = time.time()
    logger.info(f"Incoming: {request.method} {request.url.path} from IP: {client_ip}")

    try:
        # Process request
        response = await call_next(request)
        process_time = time.time() - start_time
        logger.info(f"Completed: {request.method} {request.url.path} - Status: {response.status_code} - Time: {process_time:.4f}s")
        return response
        
    except Exception as exc:
        process_time = time.time() - start_time
        logger.error(f"Failed Request: {request.method} {request.url.path} - Runtime: {process_time:.4f}s", exc_info=True)
        # Re-raise to let the top-level exception handler catch it
        raise

# ---------------------------------------------------------
# Startup & Initialization Event
# ---------------------------------------------------------
async def init_db():
    """Mock asynchronous database initialization sequence."""
    # In a full setup, this would be an Alembic migration upgrade or metadata.create_all
    logger.info("Database engine initialized successfully.")

# 4. Database initialization on startup
@app.on_event("startup")
async def startup_event():
    """Startup wrapper hook to bootstrap components."""
    logger.info("Bootstrapping AASHA API Server...")
    await init_db()

# ---------------------------------------------------------
# Exception Handlers
# ---------------------------------------------------------
# 5. Handler for 404 & HTTP Exceptions
@app.exception_handler(StarletteHTTPException)
async def custom_http_exception_handler(request: Request, exc: StarletteHTTPException):
    if exc.status_code == 404:
        return JSONResponse(
            status_code=404, 
            content={"message": "Resource not found. Please verify the API route."}
        )
    return JSONResponse(status_code=exc.status_code, content={"message": str(exc.detail)})

# 5. Handler for 500 Uncaught Exceptions
@app.exception_handler(Exception)
async def custom_internal_error_handler(request: Request, exc: Exception):
    logger.critical(f"Uncharted Internal Server Error: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500, 
        content={"message": "Internal Server Error occurred. Our engineers have been alerted."}
    )

# ---------------------------------------------------------
# Base Routes
# ---------------------------------------------------------
# 3. Dedicated Health check endpoint
@app.get("/health", tags=["system"])
async def root_health_check():
    """
    Health check endpoint to ping server availability.
    Used internally for pod/load balancer routing checks.
    """
    return {
        "status": "healthy", 
        "service": "AASHA API", 
        "timestamp": time.time()
    }

# ---------------------------------------------------------
# API Router Registration
# ---------------------------------------------------------
# 2. Main API V1 router bindings configured heavily per requested prefixes
app.include_router(auth.router, prefix="/api/v1/auth", tags=["authentication"])
app.include_router(users.router, prefix="/api/v1/users", tags=["users"])
app.include_router(ar.router, prefix="/api/v1/ar", tags=["ar"])
app.include_router(pharmacy.router, prefix="/api/v1/pharmacy", tags=["pharmacy"])
app.include_router(health.router, prefix="/api/v1/health", tags=["health"])
app.include_router(safety.router, prefix="/api/v1/safety", tags=["safety"])
app.include_router(guardian.router, prefix="/api/v1/guardians", tags=["guardians"])
app.include_router(medications.router, prefix="/api/v1/medications", tags=["medications"])

# ---------------------------------------------------------
# Serve Frontend
# ---------------------------------------------------------
import os
from fastapi.responses import FileResponse

FRONTEND_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "frontend")

@app.get("/", tags=["frontend"])
async def serve_frontend():
    return FileResponse(os.path.join(FRONTEND_DIR, "index.html"))


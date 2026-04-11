import os
import time
import logging
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.exc import OperationalError

logger = logging.getLogger("aasha.database")

# ---------------------------------------------------------
# Native Environment Hooks Configuration
# ---------------------------------------------------------
DATABASE_URL = os.getenv(
    "DATABASE_URL", 
    "sqlite:///./aasha.db"
)
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")

# 1. Native Execute Logic handling optimal limits dynamically
engine_args = {}

if "sqlite" in DATABASE_URL:
    engine_args = {"connect_args": {"check_same_thread": False}}
else:
    engine_args = {
        "pool_size": 10,
        "max_overflow": 20,
        "pool_timeout": 30,
        "pool_recycle": 1800,
    }
    # Resolve active SSL boundaries
    if ENVIRONMENT == "production" and "sslmode" not in DATABASE_URL:
        engine_args["connect_args"] = {"sslmode": "require"}

# ---------------------------------------------------------
# DB Instantiation Hook
# ---------------------------------------------------------
def establish_engine():
    import sys
    if "pytest" in sys.modules:
        return create_engine("sqlite:///./test.db", connect_args={"check_same_thread": False})

    try:
        engine = create_engine(DATABASE_URL, **engine_args)
        with engine.connect() as connection:
            logger.info("Database connection established successfully.")
            return engine
    except OperationalError as e:
        logger.warning(f"DB connection failed: {e}. Using SQLite fallback.")
        return create_engine("sqlite:///./aasha.db", connect_args={"check_same_thread": False})

engine = establish_engine()

# 2. Dependency Injection Bindings mapping local Session bindings optimally
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 3. Base instantiation executing inherently targeting all PostgreSQL Models identically natively!
Base = declarative_base()

# ---------------------------------------------------------
# 4. FastAPI Dependency Target Generator (For APIRouter hooks)
# ---------------------------------------------------------
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ---------------------------------------------------------
# 5. Startup Sequence Orchestrator Executing Models Linearly
# ---------------------------------------------------------
def init_db():
    logger.info("Initializing metadata implicitly dynamically sweeping array models directly...")
    
    # Resolves identical structural bindings actively implicitly importing internal Models handling DB generation statically!
    try:
        from app.models.user import User
        from app.models.medication import Medication, MedicationLog
        from app.models.pharmacy import Pharmacy, MedicineAvailability
        from app.models.alert import Alert
        from app.models.guardian import Guardian
        
        # Safely sweep Base targets matching natively loaded arrays implicitly generating Table constraints locally
        Base.metadata.create_all(bind=engine)
        logger.info("Structural Database loops correctly constructed missing dependencies targeting cleanly natively!")
    except Exception as e:
        logger.error(f"Failed native instantiation constraints mapping schema structures explicit limits: {e}")
        raise e

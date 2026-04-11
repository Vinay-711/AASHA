import os

class Settings:
    PROJECT_NAME: str = "AASHA"
    API_V1_STR: str = "/api/v1"
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./aasha.db")

settings = Settings()

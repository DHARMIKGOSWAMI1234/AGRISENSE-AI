import os
from typing import List, Union
from pydantic import AnyHttpUrl, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    PROJECT_NAME: str = "SMRITI Platform Backend"
    API_V1_STR: str = "/api/v1"
    
    # Security / Auth
    SECRET_KEY: str = "smriti_super_secret_development_key_change_in_production_2026_sih"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # Database (PostgreSQL or local SQLite fallback)
    DATABASE_URL: str = "sqlite:///./smriti_backend.db"
    
    # CORS
    BACKEND_CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:5173",
        "http://localhost:8000",
        "http://127.0.0.1:5173",
        "http://10.0.2.2:8000"
    ]

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )

settings = Settings()

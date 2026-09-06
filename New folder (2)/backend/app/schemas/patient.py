from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class PatientCreateRequest(BaseModel):
    display_name: str = Field(min_length=2, max_length=255)
    age: Optional[int] = Field(default=None, ge=1, le=120)
    preferred_language: str = Field(default="en", pattern="^(en|hi|as)$")
    text_size_preset: str = Field(default="Large", pattern="^(Standard|Large|Very Large)$")
    voice_assistance_enabled: bool = True
    cultural_region_tag: str = Field(default="NER_ASSAM")

class PatientUpdateRequest(BaseModel):
    display_name: Optional[str] = None
    age: Optional[int] = None
    preferred_language: Optional[str] = None
    text_size_preset: Optional[str] = None
    voice_assistance_enabled: Optional[bool] = None
    cultural_region_tag: Optional[str] = None

class PatientResponse(BaseModel):
    id: str
    caregiver_id: str
    display_name: str
    age: Optional[int]
    preferred_language: str
    text_size_preset: str
    voice_assistance_enabled: bool
    cultural_region_tag: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

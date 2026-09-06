from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class GameSessionCreateRequest(BaseModel):
    event_id: str = Field(min_length=10, max_length=64)
    patient_id: str
    game_type: str = Field(pattern="^(memory_match|pattern|routine_recall|object_memory|reminiscence)$")
    difficulty_level: int = Field(ge=1, le=10)
    accuracy: float = Field(ge=0.0, le=1.0)
    score: float = Field(ge=0.0)
    error_count: int = Field(ge=0)
    hints_used: int = Field(ge=0)
    duration_ms: int = Field(gt=0)
    recommendation_reason: Optional[str] = None
    occurred_at: datetime

class GameSessionResponse(BaseModel):
    id: str
    event_id: str
    patient_id: str
    game_type: str
    difficulty_level: int
    accuracy: float
    score: float
    error_count: int
    hints_used: int
    duration_ms: int
    recommendation_reason: Optional[str]
    occurred_at: datetime
    synced_at: datetime

    class Config:
        from_attributes = True

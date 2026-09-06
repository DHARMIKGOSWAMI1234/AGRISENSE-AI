from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class ReminderCreateRequest(BaseModel):
    reminder_type: str = Field(pattern="^(MEDICATION|HYDRATION|ACTIVITY|APPOINTMENT)$")
    title: str = Field(min_length=2, max_length=255)
    description: Optional[str] = None
    scheduled_time: str = Field(pattern=r"^\d{2}:\d{2}$") # e.g. "09:00"
    recurrence_rule: str = Field(default="DAILY")
    is_active: bool = True

class ReminderUpdateRequest(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    scheduled_time: Optional[str] = None
    recurrence_rule: Optional[str] = None
    is_active: Optional[bool] = None

class ReminderResponse(BaseModel):
    id: str
    patient_id: str
    reminder_type: str
    title: str
    description: Optional[str]
    scheduled_time: str
    recurrence_rule: str
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ReminderEventCreateRequest(BaseModel):
    event_id: str
    reminder_id: str
    patient_id: str
    action: str = Field(pattern="^(DONE|LATER|SKIP)$")
    occurred_at: datetime

from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class ActivityAlertResponse(BaseModel):
    id: str
    patient_id: str
    alert_type: str
    severity: str
    title: str
    message: str
    is_acknowledged: bool
    created_at: datetime
    acknowledged_at: Optional[datetime]

    class Config:
        from_attributes = True

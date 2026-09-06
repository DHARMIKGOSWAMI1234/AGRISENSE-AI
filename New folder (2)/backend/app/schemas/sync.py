from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
from datetime import datetime

class SyncEventItem(BaseModel):
    event_id: str
    entity_type: str = Field(pattern="^(game_session|reminder_event|patient_preference)$")
    operation: str = Field(default="INSERT", pattern="^(INSERT|UPDATE)$")
    occurred_at: datetime
    payload: Dict[str, Any]

class BatchSyncRequest(BaseModel):
    device_id: str
    client_timestamp: datetime
    events: List[SyncEventItem]

class SyncEventStatus(BaseModel):
    event_id: str
    status: str # "SYNCED", "SKIPPED_DUPLICATE", "ERROR"
    server_id: Optional[str] = None
    error_message: Optional[str] = None

class BatchSyncResponse(BaseModel):
    processed_count: int
    success_count: int
    duplicate_count: int
    error_count: int
    results: List[SyncEventStatus]
    server_time: datetime

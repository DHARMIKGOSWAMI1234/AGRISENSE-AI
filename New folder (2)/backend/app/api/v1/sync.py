from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.schemas.sync import BatchSyncRequest, BatchSyncResponse
from app.services.sync_service import SyncService

router = APIRouter(prefix="/sync", tags=["Offline Synchronization"])

@router.post("/batch", response_model=BatchSyncResponse, status_code=status.HTTP_200_OK)
def batch_sync(req: BatchSyncRequest, db: Session = Depends(get_db)):
    """
    Idempotent batch synchronization endpoint for offline mobile client.
    Deduplicates events by client-generated UUID.
    """
    return SyncService.process_batch_sync(db, req)

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.db.session import get_db
from app.models.reminder import Reminder, ReminderEvent
from app.schemas.reminder import (
    ReminderCreateRequest,
    ReminderUpdateRequest,
    ReminderResponse,
    ReminderEventCreateRequest
)

router = APIRouter(tags=["Reminders"])

@router.get("/patients/{patient_id}/reminders", response_model=List[ReminderResponse])
def list_reminders(patient_id: str, db: Session = Depends(get_db)):
    return db.query(Reminder).filter(Reminder.patient_id == patient_id).all()

@router.post("/patients/{patient_id}/reminders", response_model=ReminderResponse, status_code=status.HTTP_201_CREATED)
def create_reminder(patient_id: str, req: ReminderCreateRequest, db: Session = Depends(get_db)):
    rem = Reminder(
        patient_id=patient_id,
        reminder_type=req.reminder_type,
        title=req.title,
        description=req.description,
        scheduled_time=req.scheduled_time,
        recurrence_rule=req.recurrence_rule,
        is_active=req.is_active
    )
    db.add(rem)
    db.commit()
    db.refresh(rem)
    return rem

@router.patch("/reminders/{reminder_id}", response_model=ReminderResponse)
def update_reminder(reminder_id: str, req: ReminderUpdateRequest, db: Session = Depends(get_db)):
    rem = db.query(Reminder).filter(Reminder.id == reminder_id).first()
    if not rem:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Reminder not found.")
    
    update_data = req.model_dump(exclude_unset=True)
    for k, v in update_data.items():
        setattr(rem, k, v)
    db.commit()
    db.refresh(rem)
    return rem

@router.post("/reminder-events", status_code=status.HTTP_201_CREATED)
def record_reminder_event(req: ReminderEventCreateRequest, db: Session = Depends(get_db)):
    existing = db.query(ReminderEvent).filter(ReminderEvent.event_id == req.event_id).first()
    if existing:
        return {"status": "ALREADY_RECORDED", "id": existing.id}
    
    event = ReminderEvent(
        event_id=req.event_id,
        reminder_id=req.reminder_id,
        patient_id=req.patient_id,
        action=req.action,
        occurred_at=req.occurred_at
    )
    db.add(event)
    db.commit()
    db.refresh(event)
    return {"status": "RECORDED", "id": event.id}

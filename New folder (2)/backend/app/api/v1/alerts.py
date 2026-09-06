from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timezone
from app.db.session import get_db
from app.models.alert import ActivityAlert
from app.schemas.alert import ActivityAlertResponse

router = APIRouter(tags=["Activity Alerts"])

@router.get("/patients/{patient_id}/alerts", response_model=List[ActivityAlertResponse])
def list_patient_alerts(patient_id: str, db: Session = Depends(get_db)):
    return db.query(ActivityAlert).filter(ActivityAlert.patient_id == patient_id).order_by(ActivityAlert.created_at.desc()).all()

@router.patch("/alerts/{alert_id}/acknowledge", response_model=ActivityAlertResponse)
def acknowledge_alert(alert_id: str, db: Session = Depends(get_db)):
    alert = db.query(ActivityAlert).filter(ActivityAlert.id == alert_id).first()
    if not alert:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Alert not found.")
    alert.is_acknowledged = True
    alert.acknowledged_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(alert)
    return alert

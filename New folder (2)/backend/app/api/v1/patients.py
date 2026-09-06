from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.db.session import get_db
from app.models.user import User
from app.schemas.patient import PatientCreateRequest, PatientUpdateRequest, PatientResponse
from app.schemas.game_session import GameSessionResponse
from app.services.patient_service import PatientService
from app.services.game_session_service import GameSessionService
from app.services.ai.trends import TrendsService
from app.services.ai.recommendations import RecommendationService

router = APIRouter(prefix="/patients", tags=["Patients"])

@router.post("", response_model=PatientResponse, status_code=status.HTTP_201_CREATED)
def create_patient(req: PatientCreateRequest, caregiver_id: str = Query(...), db: Session = Depends(get_db)):
    return PatientService.create_patient(db, caregiver_id=caregiver_id, req=req)

@router.get("", response_model=List[PatientResponse])
def list_patients(caregiver_id: str = Query(...), db: Session = Depends(get_db)):
    return PatientService.get_patients_for_caregiver(db, caregiver_id=caregiver_id)

@router.get("/{patient_id}", response_model=PatientResponse)
def get_patient(patient_id: str, db: Session = Depends(get_db)):
    return PatientService.get_patient_by_id(db, patient_id=patient_id)

@router.patch("/{patient_id}", response_model=PatientResponse)
def update_patient(patient_id: str, req: PatientUpdateRequest, caregiver_id: str = Query(...), db: Session = Depends(get_db)):
    return PatientService.update_patient(db, patient_id=patient_id, caregiver_id=caregiver_id, req=req)

@router.get("/{patient_id}/sessions", response_model=List[GameSessionResponse])
def get_patient_sessions(patient_id: str, limit: int = 50, db: Session = Depends(get_db)):
    return GameSessionService.get_patient_sessions(db, patient_id=patient_id, limit=limit)

@router.get("/{patient_id}/trends")
def get_patient_trends(patient_id: str, window_days: int = 7, db: Session = Depends(get_db)):
    sessions = GameSessionService.get_patient_sessions(db, patient_id=patient_id, limit=100)
    return TrendsService.calculate_longitudinal_summary(sessions, window_days=window_days)

@router.get("/{patient_id}/recommendation")
def get_recommendation(patient_id: str, db: Session = Depends(get_db)):
    patient = PatientService.get_patient_by_id(db, patient_id=patient_id)
    sessions = GameSessionService.get_patient_sessions(db, patient_id=patient_id, limit=5)
    return RecommendationService.recommend_next_activity(
        patient_preferences={"language": patient.preferred_language},
        recent_sessions=sessions
    )

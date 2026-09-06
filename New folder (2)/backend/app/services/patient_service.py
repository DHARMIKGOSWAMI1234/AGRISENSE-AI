from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from typing import List, Optional
from app.models.patient import Patient
from app.schemas.patient import PatientCreateRequest, PatientUpdateRequest

class PatientService:
    @staticmethod
    def create_patient(db: Session, caregiver_id: str, req: PatientCreateRequest) -> Patient:
        patient = Patient(
            caregiver_id=caregiver_id,
            display_name=req.display_name,
            age=req.age,
            preferred_language=req.preferred_language,
            text_size_preset=req.text_size_preset,
            voice_assistance_enabled=req.voice_assistance_enabled,
            cultural_region_tag=req.cultural_region_tag
        )
        db.add(patient)
        db.commit()
        db.refresh(patient)
        return patient

    @staticmethod
    def get_patients_for_caregiver(db: Session, caregiver_id: str) -> List[Patient]:
        return db.query(Patient).filter(Patient.caregiver_id == caregiver_id).all()

    @staticmethod
    def get_patient_by_id(db: Session, patient_id: str, caregiver_id: Optional[str] = None) -> Patient:
        query = db.query(Patient).filter(Patient.id == patient_id)
        if caregiver_id:
            query = query.filter(Patient.caregiver_id == caregiver_id)
        patient = query.first()
        if not patient:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Patient profile not found or unauthorized access."
            )
        return patient

    @staticmethod
    def update_patient(db: Session, patient_id: str, caregiver_id: str, req: PatientUpdateRequest) -> Patient:
        patient = PatientService.get_patient_by_id(db, patient_id, caregiver_id)
        update_data = req.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(patient, key, value)
        db.commit()
        db.refresh(patient)
        return patient

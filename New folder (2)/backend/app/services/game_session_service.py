from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from typing import List, Optional
from datetime import datetime, timezone
from app.models.game_session import GameSession
from app.schemas.game_session import GameSessionCreateRequest

class GameSessionService:
    @staticmethod
    def record_session(db: Session, req: GameSessionCreateRequest) -> GameSession:
        # Check idempotency by event_id
        existing = db.query(GameSession).filter(GameSession.event_id == req.event_id).first()
        if existing:
            return existing

        session = GameSession(
            event_id=req.event_id,
            patient_id=req.patient_id,
            game_type=req.game_type,
            difficulty_level=req.difficulty_level,
            accuracy=req.accuracy,
            score=req.score,
            error_count=req.error_count,
            hints_used=req.hints_used,
            duration_ms=req.duration_ms,
            recommendation_reason=req.recommendation_reason,
            occurred_at=req.occurred_at,
            synced_at=datetime.now(timezone.utc)
        )
        db.add(session)
        db.commit()
        db.refresh(session)
        return session

    @staticmethod
    def get_patient_sessions(db: Session, patient_id: str, limit: int = 50) -> List[GameSession]:
        return db.query(GameSession)\
                 .filter(GameSession.patient_id == patient_id)\
                 .order_by(GameSession.occurred_at.desc())\
                 .limit(limit)\
                 .all()

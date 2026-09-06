import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, Float, Integer, ForeignKey, Index
from sqlalchemy.orm import relationship
from app.db.session import Base

class GameSession(Base):
    __tablename__ = "game_sessions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    event_id = Column(String(64), unique=True, index=True, nullable=False) # Stable client UUID for idempotency
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)
    game_type = Column(String(50), nullable=False) # 'memory_match', 'pattern', 'routine_recall', 'object_memory', 'reminiscence'
    difficulty_level = Column(Integer, nullable=False, default=1)
    accuracy = Column(Float, nullable=False) # 0.0 to 1.0
    score = Column(Float, nullable=False)
    error_count = Column(Integer, nullable=False, default=0)
    hints_used = Column(Integer, nullable=False, default=0)
    duration_ms = Column(Integer, nullable=False)
    recommendation_reason = Column(String(100), nullable=True) # Reason code e.g. HIGH_SUCCESS_RATE
    occurred_at = Column(DateTime(timezone=True), nullable=False)
    synced_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)

    patient = relationship("Patient", backref="sessions")

Index("idx_patient_game_occurred", GameSession.patient_id, GameSession.game_type, GameSession.occurred_at)

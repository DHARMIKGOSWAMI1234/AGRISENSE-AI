import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from app.db.session import Base

class ActivityAlert(Base):
    __tablename__ = "activity_alerts"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)
    alert_type = Column(String(50), nullable=False) # 'INACTIVITY', 'MISSED_REMINDERS', 'SYNC_DELAY'
    severity = Column(String(20), default="INFO", nullable=False) # 'INFO', 'WARNING', 'ATTENTION'
    title = Column(String(255), nullable=False)
    message = Column(String(500), nullable=False)
    is_acknowledged = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    acknowledged_at = Column(DateTime(timezone=True), nullable=True)

    patient = relationship("Patient", backref="alerts")

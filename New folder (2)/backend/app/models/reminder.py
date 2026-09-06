import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, Boolean, ForeignKey, Index
from sqlalchemy.orm import relationship
from app.db.session import Base

class Reminder(Base):
    __tablename__ = "reminders"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)
    reminder_type = Column(String(50), nullable=False) # 'MEDICATION', 'HYDRATION', 'ACTIVITY', 'APPOINTMENT'
    title = Column(String(255), nullable=False)
    description = Column(String(500), nullable=True)
    scheduled_time = Column(String(10), nullable=False) # 'HH:MM' (24-hour format)
    recurrence_rule = Column(String(50), default="DAILY", nullable=False) # 'DAILY', 'WEEKDAYS', 'CUSTOM'
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)

    patient = relationship("Patient", backref="reminders")

class ReminderEvent(Base):
    __tablename__ = "reminder_events"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    event_id = Column(String(64), unique=True, index=True, nullable=False)
    reminder_id = Column(String(36), ForeignKey("reminders.id", ondelete="CASCADE"), nullable=False, index=True)
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)
    action = Column(String(20), nullable=False) # 'DONE', 'LATER', 'SKIP'
    occurred_at = Column(DateTime(timezone=True), nullable=False)
    synced_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)

    reminder = relationship("Reminder")

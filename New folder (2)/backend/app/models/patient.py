import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, Boolean, ForeignKey, Integer
from sqlalchemy.orm import relationship
from app.db.session import Base

class Patient(Base):
    __tablename__ = "patients"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    caregiver_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    display_name = Column(String(255), nullable=False)
    age = Column(Integer, nullable=True)
    preferred_language = Column(String(10), default="en", nullable=False) # 'en', 'hi', 'as'
    text_size_preset = Column(String(20), default="Large", nullable=False) # 'Standard', 'Large', 'Very Large'
    voice_assistance_enabled = Column(Boolean, default=True, nullable=False)
    cultural_region_tag = Column(String(50), default="NER_ASSAM", nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)

    caregiver = relationship("User", backref="patients")

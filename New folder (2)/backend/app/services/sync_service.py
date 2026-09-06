from sqlalchemy.orm import Session
from datetime import datetime, timezone
from typing import List
from app.models.game_session import GameSession
from app.models.reminder import ReminderEvent
from app.schemas.sync import BatchSyncRequest, BatchSyncResponse, SyncEventStatus
from app.core.logging import logger

class SyncService:
    @staticmethod
    def process_batch_sync(db: Session, req: BatchSyncRequest) -> BatchSyncResponse:
        results: List[SyncEventStatus] = []
        success_count = 0
        duplicate_count = 0
        error_count = 0

        for event in req.events:
            try:
                if event.entity_type == "game_session":
                    existing = db.query(GameSession).filter(GameSession.event_id == event.event_id).first()
                    if existing:
                        duplicate_count += 1
                        results.append(SyncEventStatus(
                            event_id=event.event_id,
                            status="SKIPPED_DUPLICATE",
                            server_id=existing.id
                        ))
                    else:
                        payload = event.payload
                        session = GameSession(
                            event_id=event.event_id,
                            patient_id=payload.get("patient_id"),
                            game_type=payload.get("game_type"),
                            difficulty_level=payload.get("difficulty_level", 1),
                            accuracy=float(payload.get("accuracy", 0.0)),
                            score=float(payload.get("score", 0.0)),
                            error_count=int(payload.get("error_count", 0)),
                            hints_used=int(payload.get("hints_used", 0)),
                            duration_ms=int(payload.get("duration_ms", 1000)),
                            recommendation_reason=payload.get("recommendation_reason"),
                            occurred_at=event.occurred_at,
                            synced_at=datetime.now(timezone.utc)
                        )
                        db.add(session)
                        db.flush()
                        success_count += 1
                        results.append(SyncEventStatus(
                            event_id=event.event_id,
                            status="SYNCED",
                            server_id=session.id
                        ))

                elif event.entity_type == "reminder_event":
                    existing = db.query(ReminderEvent).filter(ReminderEvent.event_id == event.event_id).first()
                    if existing:
                        duplicate_count += 1
                        results.append(SyncEventStatus(
                            event_id=event.event_id,
                            status="SKIPPED_DUPLICATE",
                            server_id=existing.id
                        ))
                    else:
                        payload = event.payload
                        rem_event = ReminderEvent(
                            event_id=event.event_id,
                            reminder_id=payload.get("reminder_id"),
                            patient_id=payload.get("patient_id"),
                            action=payload.get("action", "DONE"),
                            occurred_at=event.occurred_at,
                            synced_at=datetime.now(timezone.utc)
                        )
                        db.add(rem_event)
                        db.flush()
                        success_count += 1
                        results.append(SyncEventStatus(
                            event_id=event.event_id,
                            status="SYNCED",
                            server_id=rem_event.id
                        ))
                else:
                    error_count += 1
                    results.append(SyncEventStatus(
                        event_id=event.event_id,
                        status="ERROR",
                        error_message=f"Unsupported entity_type: {event.entity_type}"
                    ))

            except Exception as ex:
                logger.error(f"Error processing sync event {event.event_id}: {str(ex)}")
                error_count += 1
                results.append(SyncEventStatus(
                    event_id=event.event_id,
                    status="ERROR",
                    error_message=str(ex)
                ))

        db.commit()

        return BatchSyncResponse(
            processed_count=len(req.events),
            success_count=success_count,
            duplicate_count=duplicate_count,
            error_count=error_count,
            results=results,
            server_time=datetime.now(timezone.utc)
        )

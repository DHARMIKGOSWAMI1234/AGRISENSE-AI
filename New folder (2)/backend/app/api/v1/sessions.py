from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.schemas.game_session import GameSessionCreateRequest, GameSessionResponse
from app.services.game_session_service import GameSessionService

router = APIRouter(prefix="/game-sessions", tags=["Game Sessions"])

@router.post("", response_model=GameSessionResponse, status_code=status.HTTP_201_CREATED)
def record_session(req: GameSessionCreateRequest, db: Session = Depends(get_db)):
    return GameSessionService.record_session(db, req)

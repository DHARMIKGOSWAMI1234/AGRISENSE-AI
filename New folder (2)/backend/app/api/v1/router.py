from fastapi import APIRouter
from app.api.v1 import auth, patients, sessions, reminders, sync, alerts

api_v1_router = APIRouter()

api_v1_router.include_router(auth.router)
api_v1_router.include_router(patients.router)
api_v1_router.include_router(sessions.router)
api_v1_router.include_router(reminders.router)
api_v1_router.include_router(sync.router)
api_v1_router.include_router(alerts.router)

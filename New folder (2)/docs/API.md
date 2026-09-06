# SMRITI REST API Specification (v1)

Base URL: `/api/v1`

## 1. Authentication Endpoints
- `POST /auth/register` - Register a new caregiver or health-worker account.
- `POST /auth/login` - Authenticate with email/password and obtain JWT access & refresh tokens.
- `POST /auth/refresh` - Refresh an expired access token using a valid refresh token.
- `GET /auth/me` - Retrieve current authenticated user profile and roles.

## 2. Patient & Caregiver Endpoints
- `GET /patients` - List all patients linked to the authenticated caregiver/worker.
- `POST /patients` - Create a new patient profile (name, preferred language, text size, voice assistance).
- `GET /patients/{id}` - Get patient details, today's activity status, and active alerts.
- `PATCH /patients/{id}` - Update patient preferences and settings.

## 3. Game Sessions & Synchronization
- `POST /game-sessions` - Direct upload of a single game session event.
- `GET /patients/{id}/sessions` - Query longitudinal game sessions with date filters.
- `POST /sync/batch` - Idempotent batch upload of offline-queued events (game sessions, reminder events, preference updates).
- `GET /sync/changes` - Pull server-side configuration changes (updated reminders, routines) since a timestamp.

## 4. Reminders & Routines
- `GET /patients/{id}/reminders` - List scheduled reminders for a patient.
- `POST /patients/{id}/reminders` - Create a new reminder (medicine, hydration, activity).
- `PATCH /reminders/{id}` - Update or deactivate a reminder.
- `POST /reminder-events` - Record patient response (`DONE`, `LATER`, `SKIP`).

## 5. Alerts & Analytics
- `GET /patients/{id}/alerts` - List active non-diagnostic activity alerts.
- `PATCH /alerts/{id}/acknowledge` - Acknowledge or dismiss an alert.
- `GET /patients/{id}/analytics` - Aggregated engagement trends, domain breakdown, and Cognitive Engagement Index.

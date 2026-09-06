# SMRITI System Architecture Specification

## 1. High-Level Architecture

SMRITI is architected as an **offline-first, distributed cognitive assistance ecosystem** composed of four decoupled subsystems:

```
+-------------------------------------------------------------+
|                     PATIENT CLIENT (Flutter)                |
|  +---------------------+   +-----------------------------+  |
|  |   Elderly-First UI  |   | 5 Cognitive Games Engine    |  |
|  |  (Large UI, Voice)  |   | (Memory, Pattern, Routine)  |  |
|  +----------+----------+   +--------------+--------------+  |
|             |                             |                 |
|             v                             v                 |
|  +-------------------------------------------------------+  |
|  |            Local Repository & State Layer             |  |
|  +--------------------------+----------------------------+  |
|                             |                               |
|                             v                               |
|  +-------------------------------------------------------+  |
|  |             ACID SQLite Database (Drift/sqflite)       |  |
|  |  - game_sessions       - sync_queue                   |  |
|  |  - patient_preferences - reminder_events              |  |
|  +--------------------------+----------------------------+  |
|                             |                               |
|                             v (Opportunistic Sync)          |
|  +-------------------------------------------------------+  |
|  |             Client Sync Engine (Exponential Backoff)  |  |
|  +--------------------------+----------------------------+  |
+-----------------------------|-------------------------------+
                              | HTTPS / JSON (Batch UUIDs)
                              v
+-------------------------------------------------------------+
|                    BACKEND SERVER (FastAPI)                 |
|  +-------------------------------------------------------+  |
|  |           API Gateway & RBAC Auth (/api/v1)           |  |
|  +--------------------------+----------------------------+  |
|                             |                               |
|         +-------------------+-------------------+           |
|         |                   |                   |           |
|         v                   v                   v           |
|  +--------------+   +---------------+   +---------------+   |
|  | Sync Service |   | Patient Serv. |   | AI Engine     |   |
|  | (Idempotent) |   | & Reminders   |   | (Explainable) |   |
|  +-------+------+   +-------+-------+   +-------+-------+   |
|          |                  |                   |           |
|          +------------------+-------------------+           |
|                             |                               |
|                             v                               |
|  +-------------------------------------------------------+  |
|  |            PostgreSQL 16 Relational Database          |  |
|  +-------------------------------------------------------+  |
+-----------------------------^-------------------------------+
                              | REST API / JWT
+-----------------------------|-------------------------------+
|             CAREGIVER & HEALTH WORKER DASHBOARD             |
|                  (React + TypeScript + Vite)                |
|  +----------------------+  +-----------------------------+  |
|  | Longitudinal Trends  |  | Reminder & Alert Manager    |  |
|  | (Non-Diagnostic)     |  | Sync Status Monitor         |  |
|  +----------------------+  +-----------------------------+  |
+-------------------------------------------------------------+
```

---

## 2. Core Subsystems

### 2.1 Mobile Application (`mobile/`)
- **Framework:** Flutter 3.x (Dart 3.x) targeting Android phones & tablets.
- **Design System:** `ElderlyTheme` providing $\ge 56\,\text{dp}$ touch targets, WCAG AAA contrast, system font scaling, and zero flickering animations.
- **Local Store:** SQLite using transactional ACID properties. Local DB is the single source of truth; UI components never query external networks directly.
- **Games:** 5 structured cognitive games (Memory Match, Pattern Recognition, Daily Routine Recall, Remember the Objects, Reminiscence).
- **Adaptive Engine:** Tier 0 deterministic rule engine calculating next difficulty level with structured reason codes.

### 2.2 Backend Application (`backend/`)
- **Framework:** FastAPI with Python 3.11+.
- **Database:** PostgreSQL 16 managed via SQLAlchemy ORM and Alembic migrations.
- **Security:** JWT authentication with Argon2/bcrypt password hashing and Role-Based Access Control (`PATIENT`, `CAREGIVER`, `HEALTHCARE_WORKER`, `ADMIN`).
- **Sync Protocol:** Idempotent batch upload endpoint (`POST /api/v1/sync/batch`) consuming client-generated UUID events.

### 2.3 Machine Learning Pipeline (`ml/`)
- **Framework:** Scikit-learn, Pandas, NumPy.
- **Task:** Difficulty adaptation and session completion prediction.
- **Strategy:** Leakage-free `GroupKFold` patient splitting, comparing rule baseline against Logistic Regression, Random Forest, and XGBoost models.

### 2.4 Caregiver Web Console (`dashboard/`)
- **Framework:** React 18, TypeScript, Vite, Tailwind CSS, Lucide Icons, Recharts.
- **Purpose:** Non-diagnostic visualization of patient adherence, engagement trends, and alerts.

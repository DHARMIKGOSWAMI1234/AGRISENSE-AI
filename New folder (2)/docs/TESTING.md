# SMRITI Verification & Testing Strategy

## Test Levels & Execution Matrix

### 1. Backend Pytest Suite
- **Location:** `backend/tests/`
- **Commands:**
  ```bash
  cd backend
  pytest -v --cov=app tests/
  ```
- **Scope:** Auth token hashing & RBAC, session recording, batch UUID idempotency, validation error schemas.

### 2. Mobile Flutter Tests
- **Location:** `mobile/test/`
- **Commands:**
  ```bash
  cd mobile
  flutter test
  ```
- **Scope:** ElderlyTheme contrast, game controllers (Memory Match, Pattern, Routine Recall), Tier 0 adaptive engine rules, local database serialization.

### 3. ML Pipeline Tests
- **Location:** `ml/tests/`
- **Commands:**
  ```bash
  cd ml
  pytest -v tests/
  ```
- **Scope:** Patient group split integrity (zero leakage), feature scaling ranges, model inference latency (<50ms).

### 4. End-to-End Offline Sync Verification
1. Start mobile client with internet disabled.
2. Complete cognitive game session; verify record in local SQLite database.
3. Verify sync queue entry created with status `PENDING`.
4. Restore internet connectivity.
5. Trigger sync engine; verify upload to backend.
6. Verify record appears on Caregiver Dashboard with updated trend chart.
7. Trigger sync again; verify server idempotency acknowledges without duplicate creation.

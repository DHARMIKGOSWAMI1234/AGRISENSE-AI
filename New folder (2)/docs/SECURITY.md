# SMRITI Security & Threat Model

## 1. Security Principles
- **Defense in Depth:** Multiple layers of validation at Client, API Gateway, Service Layer, and Database.
- **Zero Plaintext Secrets:** Passwords hashed with Argon2id / bcrypt. Secrets stored in environment variables, never version control.
- **Role-Based Access Control (RBAC):** Every endpoint verifies token role (`PATIENT`, `CAREGIVER`, `HEALTHCARE_WORKER`, `ADMIN`).
- **Idempotent Batch Sync:** Prevents replay attacks and duplicate event generation via UUID validation.

## 2. Threat Analysis & Mitigations

| Threat Vector | Risk Level | SMRITI Technical Mitigation |
|---|---|---|
| **Stolen Device / Local Access** | High | SQLite encryption ready; sensitive tokens in platform-native secure storage; minimal PII stored locally. |
| **Unauthorized Caregiver Access** | High | Cryptographically signed JWT tokens with 60-minute expiration; caregiver-patient ownership verification on all resource queries. |
| **Tampered Game Session Payloads** | Medium | Server-side validation of metrics ($0.0 \le \text{accuracy} \le 1.0$, $\text{duration} > 0$); immutable append-only event log. |
| **Replay & Network Duplication** | Medium | Client-generated UUIDs; server database enforces `UNIQUE` constraint on `event_id`. |
| **PII Leakage in Server Logs** | High | Structured logging middleware automatically masks passwords, tokens, and patient names. |
| **API Denial of Service / Spam** | Medium | Rate limiting middleware applied to `/api/v1/auth/*` endpoints. |

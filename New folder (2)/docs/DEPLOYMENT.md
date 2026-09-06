# SMRITI Deployment Architecture

## 1. Containerized Multi-Service Deployment
SMRITI supports zero-friction local and cloud deployment via Docker Compose:
- **`smriti_postgres`**: PostgreSQL 16 Alpine container with healthchecks and persistent volume mount.
- **`smriti_backend`**: FastAPI asynchronous Python 3.11 container with multi-worker Uvicorn.
- **`smriti_dashboard`**: React / Vite production build served via lightweight Nginx / Node runner.

## 2. Production Hardening Checklist
- [ ] Enforce HTTPS (TLS 1.3) with HSTS headers.
- [ ] Enable PostgreSQL SSL connection mode.
- [ ] Rotate JWT Secret Keys in AWS Secrets Manager / Azure Key Vault.
- [ ] Restrict CORS origins to verified caregiver dashboard domains.
- [ ] Deploy CDN caching for static NER audio and image content packs.

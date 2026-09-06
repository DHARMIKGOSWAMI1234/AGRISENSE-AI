# SMRITI (স্মৃতি / स्मृति)
> **AI-Powered Cognitive Gaming and Memory Assistance Platform for Elderly Dementia Patients in the North Eastern Region (NER)**  
> *Engineered for Smart India Hackathon (SIH 2026)*

---

## 📌 Executive Summary

**SMRITI** is an elderly-first, offline-first cognitive companion designed to bridge the healthcare and digital divide for elderly dementia patients across North Eastern India. Rather than presenting generic brain-training mini-games, SMRITI integrates **daily routine recall, culturally localized memory tasks, explainable adaptive intelligence, and durable offline-first synchronization** into a unified caregiver support loop:

$$\text{Engage} \longrightarrow \text{Measure} \longrightarrow \text{Personalize} \longrightarrow \text{Remind} \longrightarrow \text{Sync} \longrightarrow \text{Inform Caregiver}$$

### 🛡️ Non-Diagnostic Medical Boundary
*SMRITI is a supportive cognitive engagement and memory assistance tool—**NEVER** a diagnostic system, disease severity classifier, or replacement for qualified clinical professionals.* System analytics report objective engagement metrics (e.g., *Activity Completion*, *Recall Response Time*, *Consistency Score*) rather than clinical disease assertions.

---

## 🤖 WHAT THE AI DOES TODAY

1. **SMRITI records real in-app gameplay performance**: Captures objective session latency, accuracy, error streaks, hint usage, and completion metrics.
2. **Tier 0 rule engine evaluates recent performance**: Deterministic, clinical threshold rules evaluate recent patient engagement trends locally on device and backend.
3. **The system adjusts difficulty using explainable rules**: Every step up (`INCREASE`), down (`DECREASE`), or maintain (`MAINTAIN`) produces a transparent clinical reason code (e.g., `HIGH_SUCCESS_RATE`, `LOW_ACCURACY`, `FATIGUE_DETECTED`, `REPEATED_ERRORS`).
4. **Tier 1 research models provide behavioral calibration / reference analysis**: Real OpenNeuro datasets (`ds000164` Stroop & `ds000102` Flanker) provide empirical healthy-adult behavioral reference distributions to inform engineering parameters.
5. **NO model diagnoses dementia**: SMRITI enforces an absolute non-diagnostic medical boundary.
6. **NO model claims clinical efficacy**: Models are not medical devices.
7. **Future adaptive ML requires sufficient genuine consented SMRITI telemetry**: Tier 2 personalization models will only be trained when longitudinal consented in-app interaction data is gathered with independent observational outcomes (`next_difficulty_completion_success`).

---

## 🏛️ Multi-Tier Architecture

SMRITI strictly separates clinical decision logic, open-science empirical calibration, and future consented machine learning:

1. **Tier 0 (Production Decision Engine):** Explainable, deterministic rule engine running locally on device and backend with structured audit reason codes (`HIGH_SUCCESS_RATE`, `LOW_ACCURACY`, `SLOW_RESPONSE`, `REPEATED_ERRORS`, `FATIGUE_DETECTED`, `MAINTAIN_CURRENT_LEVEL`).
2. **Tier 1 (Empirical Cognitive Calibration & Research Benchmarks):** Ingested 4,585 empirical behavioral trials from **OpenNeuro** (`ds000164` Stroop Task, 28 subjects; `ds000102` Flanker Task, 26 subjects) to provide empirical healthy-adult reference distributions. *These data may inform initial engineering ranges and experimental parameterization, but they are not representative of elderly dementia populations and must not be interpreted as clinical normative thresholds.*
3. **Tier 2 (Future Consented In-App ML):** Continuous pseudonymized telemetry stream (`/api/v1/game-sessions`) collecting consented longitudinal patient interactions to train future personalization models against an independent observational target (`next_difficulty_completion_success`).

```text
SMRITI Architecture
├── mobile/            # Flutter / Dart Elderly-First Mobile Client (Offline-First, SQLite)
├── backend/           # FastAPI / PostgreSQL Backend (RBAC Auth, Batch Idempotent Sync)
├── dashboard/         # React / TypeScript / Vite Caregiver & Health-Worker Console
├── data/              # Real-World Datasets & Cryptographic Manifests
│   ├── raw/           # OpenNeuro BIDS raw events.tsv files
│   ├── processed/     # Standardized empirical trials & statistical audit JSON
│   ├── checksums/     # SHA-256 cryptographic verification hashes
│   └── manifests/     # Machine-readable dataset provenance manifest (datasets.json)
├── ml/                # Machine Learning & Multi-Tier Inference Engine
│   ├── models/        # Registry of calibrated models & archived leakage demos
│   ├── training/      # Reproducible GroupKFold training scripts
│   ├── inference/     # Tier 0 Rule + Tier 1 Cognitive Estimators
│   └── tests/         # Leakage regression & provenance tests
├── docs/              # Master Engineering, Security, Privacy, Dataset Governance Specs
└── scripts/           # Automation, Data Ingestion, and Verification Scripts
```

---

## 🚀 Key Architectural Pillars

1. **Elderly-First UX Design:** High contrast, large touch targets ($\ge 56\,\text{dp}$), readable typography with system font scaling, calm non-punitive feedback, and frictionless patient access.
2. **Offline-First Resilience:** Local SQLite database acts as the single source of truth. All game sessions, reminder events, and routine completions persist locally first and sync opportunistically via durable UUID-based queues.
3. **Culturally Localized (NER Focus):** Regional content packs featuring familiar artifacts (*Japi, Gamusa, Xaak, Sarai, Pitha*) and landscapes, with support for **English, Hindi, Assamese**, and extensible NER language variants.
4. **Explainable Adaptive AI:** Tier 0 deterministic rule engine paired with calibrated OpenNeuro empirical benchmarks. Every adaptation includes a human-readable reason code.
5. **Caregiver & Worker Visibility:** Responsive React dashboard providing longitudinal trends, adherence tracking, non-diagnostic alerts, and sync status monitoring.

---

## 📂 Quick Start & Local Setup

### 1. Prerequisites
- **Flutter SDK:** $\ge 3.24.0$
- **Python:** $\ge 3.11$
- **Node.js & npm:** $\ge 20.x$

### 2. Running Services Locally

#### Backend (FastAPI):
```bash
cd backend
python -m venv .venv
# On Windows: .venv\Scripts\activate | On Linux/macOS: source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

#### Caregiver Dashboard (React / Vite):
```bash
cd dashboard
npm install
npm run dev
```

#### Mobile Application (Flutter):
```bash
cd mobile
flutter pub get
flutter run
```

#### Dataset Download & ML Calibration:
```bash
# 1. Download & verify OpenNeuro real cognitive corpora (SHA-256 verified)
python scripts/data/download_openneuro_cognitive.py
python scripts/data/verify_datasets.py

# 2. Preprocess and generate statistical audit
python scripts/data/preprocess_openneuro_cognitive.py

# 3. Train real ML models with 5-Fold GroupKFold (Zero subject leakage)
python ml/training/train_real_models.py

# 4. Run leakage regression & provenance test suite
python -m unittest discover -s ml/tests -p "test_*.py"
```

---

## 📋 Documentation Sitemap
- [`docs/DATASET_PROVENANCE.md`](file:///docs/DATASET_PROVENANCE.md): Cryptographic provenance for all OpenNeuro, speech, and clinical datasets.
- [`docs/DATASET_AUDIT.md`](file:///docs/DATASET_AUDIT.md): Programmatic statistical distributions (RT, accuracy, conditions).
- [`docs/DATA_DICTIONARY.md`](file:///docs/DATA_DICTIONARY.md): Complete field taxonomy (Raw vs Derived vs Engineered vs Target).
- [`docs/DATASET_REGISTRY.md`](file:///docs/DATASET_REGISTRY.md): Master dataset classification table.
- [`docs/ML_LEAKAGE_AUDIT.md`](file:///docs/ML_LEAKAGE_AUDIT.md): 7-dimensional leakage audit.
- [`docs/MODEL_CARD.md`](file:///docs/MODEL_CARD.md): Three-tier model cards and benchmark performance tables.
- [`docs/MASTER_REQUIREMENTS_TRACEABILITY.md`](file:///docs/MASTER_REQUIREMENTS_TRACEABILITY.md): Complete traceability matrix for SIH 2026.

---

## 📄 License & Ethical Conduct
Developed for the Smart India Hackathon. All datasets, cultural content metadata, and code components respect privacy by design, data minimization, and ethical AI principles.

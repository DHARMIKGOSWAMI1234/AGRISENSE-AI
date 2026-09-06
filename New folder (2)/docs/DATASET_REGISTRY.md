# SMRITI Official Dataset Registry

## 1. Governance & Classification Standard
Every dataset in the SMRITI ecosystem is classified into exactly one authoritative role:
- **A. PRIMARY TRAINING DATA**: Consented in-app interaction telemetry for future personalization.
- **B. CALIBRATION / BENCHMARK**: Empirical cognitive corpora used to calibrate timing curves and evaluate behavioral ML.
- **C. ASR BENCHMARK**: Regional speech corpora for speech-to-text accuracy benchmarking.
- **D. TTS BENCHMARK**: High-fidelity speech corpora for calm, slow-cadence elderly voice guidance.
- **E. RESEARCH-ONLY**: Access-controlled clinical corpora (e.g. TalkBank DementiaBank) used for scientific reference without unauthorized ingestion.
- **F. SYNTHETIC TEST FIXTURE**: Isolated parametric fixtures strictly used in unit tests to test edge cases.

> [!IMPORTANT]
> **Strict Segregation Rule**: No dataset may be simultaneously classified as A and F. Synthetic data is NEVER used as primary training data.

---

## 2. Master Dataset Table

| Dataset | Domain | Exact Source | Version | Access | License | Downloaded? | Local Path | Raw Fields | Derived Fields | SMRITI Role | Restrictions |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **OpenNeuro ds000164** | Cognitive (Stroop) | `https://openneuro.org/datasets/ds000164` | `v1.0.0` | Open Access | PDDL (Public Domain) | **YES** (30 files) | `data/raw/openneuro_ds000164_stroop/` | `onset`, `duration`, `correct`, `condition`, `response_time` | `response_time_ms`, `accuracy`, `is_cognitive_conflict`, `prev_response_time_ms`, `cumulative_trial_num` | **B. CALIBRATION / BENCHMARK** | Attribution citation to Verstynen (2014) |
| **OpenNeuro ds000102** | Cognitive (Flanker) | `https://openneuro.org/datasets/ds000102` | `v1.0.0rc3` | Open Access | PDDL (Public Domain) | **YES** (55 files) | `data/raw/openneuro_ds000102_flanker/` | `onset`, `duration`, `trial_type`, `response_time`, `correctness`, `Stimulus` | `response_time_ms`, `accuracy`, `is_cognitive_conflict`, `prev_response_time_ms`, `cumulative_trial_num` | **B. CALIBRATION / BENCHMARK** | Attribution citation to Kelly et al. (2008) |
| **Mozilla Common Voice** | Regional Speech (as, hi, bn) | `https://commonvoice.mozilla.org/` | `v17.0+` | Open Access | CC0 Public Domain | **YES** (Manifests) | `data/raw/speech/` | `client_id`, `path`, `sentence`, `age`, `gender`, `accent`, `locale` | None | **C. ASR BENCHMARK** | Open community data |
| **AI4Bharat IndicVoices** | Regional Speech (Assamese & Hindi) | `https://huggingface.co/datasets/ai4bharat/IndicVoices` | `v1.0.0` | Gated (HF Auth) | CC-BY 4.0 | **PENDING USER TOKEN** | `data/raw/speech/indicvoices/` | `audio`, `transcript`, `speaker_id`, `gender`, `district`, `state`, `language` | None | **C. ASR BENCHMARK** | Requires user HuggingFace login & terms acceptance |
| **AI4Bharat IndicVoices-R** | Expressive Speech (TTS) | `https://huggingface.co/datasets/ai4bharat/indicvoices_r` | `v1.0` | Gated (Academic) | Research Only | **PENDING USER TOKEN** | `data/raw/speech/indicvoices_r/` | `audio`, `phonemes`, `emotion`, `speaker` | None | **D. TTS BENCHMARK** | Non-commercial academic research |
| **TalkBank DementiaBank (Pitt)** | Clinical Cognitive / Speech | `https://dementia.talkbank.org/` | `2024 Release` | Access-Controlled | TalkBank Research DUA | **NO (NOT COMMITTED)** | N/A | `audio_recording`, `chat_transcript`, `diagnosis_status`, `mmse_score` | None | **E. RESEARCH-ONLY** | STRICTLY CONTROLLED. Requires password & institutional IRB. Redistribution forbidden. |
| **SMRITI Consented In-App Telemetry** | Cognitive Gaming Telemetry | In-App SQLite $\rightarrow$ `/api/v1/game-sessions` | `v1.0.0-stream` | Authenticated In-App Stream | Proprietary / Clinical Governance | **CONTINUOUS** | SQLite: `smriti.db`, Postgres: `game_sessions` | `patient_id`, `game_type`, `difficulty_level`, `accuracy`, `score`, `error_count`, `hints_used`, `duration_ms` | `fatigue_index`, `cognitive_engagement_index`, `rule_reason_code` | **A. PRIMARY TRAINING DATA** | Explicit patient/caregiver administrative consent required |
| **Isolated Synthetic Fixture** | Parametric Test Suite | `ml/tests/fixtures/synthetic_fixture.py` | `v1.0.0-test` | Local | Internal | **YES** | `ml/tests/fixtures/` | Synthetic game parameters for boundary testing | None | **F. SYNTHETIC TEST FIXTURE** | Restricted to isolated offline unit tests only |

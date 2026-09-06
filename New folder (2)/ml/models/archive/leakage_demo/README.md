# ARCHIVED LEAKAGE DEMONSTRATION ARTIFACTS

> [!CAUTION]
> **INVALID FOR PRODUCTION | INVALID FOR SCIENTIFIC PERFORMANCE CLAIMS**
> The artifacts in this directory are preserved strictly as negative test references and historical audit evidence. They must NEVER be used in production or cited as empirical machine-learning performance.

## Root Cause Summary
1. **Synthetic Subject Identifiers (`SUBJ_NER_001` - `SUBJ_NER_150`)**:
   - The data previously in `cognitive_performance_trials.csv` was generated from a parametric Monte Carlo script (`deprecated_synthetic_generator.py`) rather than downloaded directly from open science repositories.
2. **Deterministic Target Leakage (`target_action`)**:
   - The labels `DECREASE (-1)`, `MAINTAIN (0)`, `INCREASE (+1)` were computed deterministically from input features (`accuracy`, `response_time_ms`, `consecutive_errors`) using `if/else` conditions.
   - Any supervised classifier trained on these labels merely learned to approximate the deterministic decision tree generator, resulting in artificial 100% accuracy.
3. **Corrective Action**:
   - Ingested 4,585 genuine empirical trials from OpenNeuro (`ds000164` Stroop Task, 28 participants; `ds000102` Flanker Task, 26 participants) located in `data/raw/` and `data/processed/`.
   - Production adaptive engine uses Tier 0 explainable rule-based adaptation (`MobileAdaptiveEngine` / `backend/app/services/ai/adaptive.py`) with explicit audit reason codes.
   - Legitimate empirical ML models are trained on genuine targets (e.g. empirical reaction time regression and cognitive conflict classification) using subject-level `GroupKFold`.

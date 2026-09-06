# SMRITI Model Card & Multi-Tier Architecture

## 1. Executive Status & Governance Overview

| Tier / System Component | Current Implementation Status | Operational Nature | SMRITI Role |
| :--- | :--- | :--- | :--- |
| **CURRENT PRODUCTION** | **Active & Live** | Rule-Based Adaptive Engine | Deterministic, explainable patient-facing difficulty adjustment using real session telemetry. |
| **CURRENT ML** | **Trained & Serialized** | Tier 1 Research / Calibration Models | Open-science healthy-adult empirical benchmarks (`ds000164` Stroop & `ds000102` Flanker). |
| **NOT CURRENTLY AVAILABLE** | **Not Implemented / No Data** | Validated Patient-Specific Adaptive ML | Will not be claimed until longitudinal clinical telemetry is collected under consent. |
| **FUTURE ML** | **Telemetry Stream Designed** | Consent-Based Longitudinal Telemetry ML | Supervised personalization trained on genuine consented SMRITI in-app telemetry. |

> [!IMPORTANT]
> **Scientific Validity & Non-Clinical Disclaimer**:
> The OpenNeuro datasets provide empirical healthy-adult behavioral reference distributions for reaction time and cognitive interference. These data may inform initial engineering ranges and experimental parameterization, but they are not representative of elderly dementia populations and must not be interpreted as clinical normative thresholds. High performance on external cognitive-task datasets does not imply clinical validity or dementia-related predictive validity.
>
> SMRITI models DO NOT diagnose dementia, DO NOT predict dementia, DO NOT predict SMRITI game difficulty, DO NOT establish clinical timeout thresholds, and DO NOT demonstrate clinical efficacy. Production timeout parameters must remain configurable. Future validation must come from elderly usability testing, caregiver/user feedback, safe in-app telemetry where consented, and future research datasets where legally and ethically appropriate.

---

## 2. System Architecture

```
+-----------------------------------------------------------------------------------+
|                            TIER 0: PRODUCTION ENGINE                              |
|   Deterministic, Rule-Based Adaptive Engine with Structured Audit Reason Codes   |
|   (Mobile: MobileAdaptiveEngine | Backend: backend/app/services/ai/adaptive.py)   |
+-----------------------------------------------------------------------------------+
                                      ▲
                                      │ Informs experimental engineering ranges
                                      │ (NOT clinical normative thresholds)
+-----------------------------------------------------------------------------------+
|                        TIER 1: EMPIRICAL CALIBRATION                              |
|   Real OpenNeuro Corpora (ds000164 Stroop & ds000102 Flanker - 4,585 trials)      |
|   Task A: Empirical RT Regressor | Task B: Research Conflict Benchmark            |
+-----------------------------------------------------------------------------------+
                                      ▲
                                      │ Ingests consented session stream
                                      │ with independent observational target
+-----------------------------------------------------------------------------------+
|                        TIER 2: FUTURE CONSENTED ML                                |
|   Consented In-App Telemetry Stream (SQLite -> PostgreSQL /api/v1/game-sessions)   |
|   Proposed Target: 'next_difficulty_completion_success' (Independently Observed) |
+-----------------------------------------------------------------------------------+
```

---

## 3. Tier 0: Explainable Production Adaptive Engine
- **Classification:** **RULE-BASED ADAPTATION** (Explicitly NOT a black-box ML model).
- **Patient-Facing:** YES.
- **Input Telemetry:**
  - `recent_accuracy` (Float $[0.0, 1.0]$)
  - `response_latency_ms` (Integer milliseconds)
  - `repeated_errors` (Integer count)
  - `repeated_successes` (Integer count)
  - `completion_rate` (Float $[0.0, 1.0]$)
  - `hints_used` (Integer count)
  - `fatigue_indicators` (Pacing deviation)
- **Output Action:** `DECREASE (-1)`, `MAINTAIN (0)`, `INCREASE (+1)`
- **Explainability Reason Codes:**
  - `HIGH_SUCCESS_RATE`: Accuracy $\ge 85\%$, stable reaction time, consecutive successes $\ge 2$.
  - `LOW_ACCURACY`: Accuracy $< 60\%$ or repeated errors $\ge 2$.
  - `SLOW_RESPONSE`: Latency $> 8000\text{ ms}$ or timeout breach.
  - `REPEATED_ERRORS`: Multiple consecutive missteps.
  - `FATIGUE_DETECTED`: Reaction time slowing $> 40\%$ over baseline.
  - `FATIGUE_OR_ABANDONMENT`: Session completion rate $< 50\%$.
  - `MAINTAIN_CURRENT_LEVEL`: Stable performance within comfort zone.

---

## 4. Tier 1: Real-World Empirical Cognitive Models (Research / Calibration)

### Task A (Regression): Empirical Response-Latency Prediction
- **Task**: Empirical response-latency prediction under cognitive load.
- **Role**: Tier 1 behavioral research / calibration benchmark (**NOT** clinical prediction, **NOT** dementia diagnosis, **NOT** difficulty prediction).
- **Dataset**: OpenNeuro `ds000164` (Stroop, Snapshot `1.0.0`) + `ds000102` (Flanker, Snapshot `1.0.0rc3`).
- **Target**: `response_time_ms` (Observed physical button-press latency in milliseconds).
- **Features**: `is_cognitive_conflict`, `cumulative_trial_num`, `prev_response_time_ms`, `prev_accuracy`, `task_is_stroop`.
- **Validation Scheme**: 5-Fold `GroupKFold` grouped strictly by `participant_id` (54 subjects; zero subject leakage).
- **Benchmark Performance (Holdout Subject Groups)**:
  - **Dummy Mean Baseline**: $\text{MAE} = 147.88\text{ ms} \mid \text{RMSE} = 195.78\text{ ms} \mid R^2 = -0.0054$
  - **Linear Regression**: $\text{MAE} = 129.49\text{ ms} \mid \text{RMSE} = 174.33\text{ ms} \mid R^2 = 0.1929$
  - **Ridge Regression**: $\text{MAE} = 129.49\text{ ms} \mid \text{RMSE} = 174.33\text{ ms} \mid R^2 = 0.1929$
  - **Random Forest Regressor (Best)**: $\mathbf{\text{MAE} = 126.45\text{ ms} \mid \text{RMSE} = 170.85\text{ ms} \mid R^2 = 0.2268}$
  - **Gradient Boosting Regressor**: $\text{MAE} = 127.51\text{ ms} \mid \text{RMSE} = 172.30\text{ ms} \mid R^2 = 0.2144$
- **Artifact**: `ml/models/registry/cognitive_reaction_time_regressor.joblib`

### Task B (Classification): Cognitive Conflict Research Benchmark
- **Task**: Binary cognitive conflict classification from behavioral metrics.
- **Role**: **RETAINED AS A REPRODUCIBLE BEHAVIORAL CLASSIFICATION BENCHMARK ONLY.** Demonstrates that the pipeline can learn an observed experimental condition from behavioral signals. **It is NOT used to make patient-facing decisions.**
- **Dataset**: OpenNeuro `ds000164` + `ds000102` (4,525 trials across 54 subjects).
- **Target**: `is_cognitive_conflict` ($1$ = Incongruent interference, $0$ = Congruent/Neutral).
- **Validation Scheme**: 5-Fold `GroupKFold` by `participant_id`.
- **Benchmark Performance (Holdout Subject Groups)**:
  - **Dummy Stratified Baseline**: $\text{Accuracy} = 0.5419 \mid \text{Balanced Acc} = 0.5004 \mid \text{Macro F1} = 0.5002$
  - **Logistic Regression**: $\text{Accuracy} = 0.6826 \mid \text{Balanced Acc} = 0.5974 \mid \text{Macro F1} = 0.5924$
  - **Random Forest Classifier**: $\text{Accuracy} = 0.6822 \mid \text{Balanced Acc} = 0.6090 \mid \text{Macro F1} = 0.6096$
  - **Gradient Boosting Classifier (Best)**: $\mathbf{\text{Accuracy} = 0.6828 \mid \text{Balanced Acc} = 0.6143 \mid \text{Macro F1} = 0.6165}$
  - **Extra Trees Classifier**: $\text{Accuracy} = 0.6767 \mid \text{Balanced Acc} = 0.5774 \mid \text{Macro F1} = 0.5614$
- **Artifact**: `ml/models/registry/cognitive_conflict_classifier.joblib`

---

## 5. Tier 2: Future In-App Machine Learning Roadmap
- **Data Source**: Genuine SMRITI patient interaction telemetry stream (`/api/v1/game-sessions`).
- **Proposed Future Target**: `next_difficulty_completion_success` (Observed independent binary outcome: did the patient successfully complete the next level within allowable time and error margins?).
- **Current Operational Status**: **PROPOSED FUTURE TARGET ONLY. NOT TRAINED TODAY.** Zero synthetic examples will be generated to train this model. Model training will commence only after authentic consented longitudinal patient sessions are recorded.

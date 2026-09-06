# SMRITI Model Card & Multi-Tier Architecture

## 1. System Architecture Overview

SMRITI implements a strict three-tier architecture that separates explainable production clinical decision logic, open-science empirical calibration, and future consented machine learning:

```
+-----------------------------------------------------------------------------------+
|                            TIER 0: PRODUCTION ENGINE                              |
|   Deterministic, Rule-Based Adaptive Engine with Structured Audit Reason Codes   |
|   (Mobile: MobileAdaptiveEngine | Backend: backend/app/services/ai/adaptive.py)   |
+-----------------------------------------------------------------------------------+
                                      ▲
                                      │ Calibrates response time cutoffs
                                      │ and timeout thresholds
+-----------------------------------------------------------------------------------+
|                        TIER 1: EMPIRICAL CALIBRATION                              |
|   Real OpenNeuro Corpora (ds000164 Stroop & ds000102 Flanker - 4,585 trials)      |
|   Models: Reaction-Time Regressor & Cognitive Conflict Classifier                 |
+-----------------------------------------------------------------------------------+
                                      ▲
                                      │ Ingests consented session stream
                                      │ with independent observational target
+-----------------------------------------------------------------------------------+
|                        TIER 2: FUTURE CONSENTED ML                                |
|   Consented In-App Telemetry Stream (SQLite -> PostgreSQL /api/v1/game-sessions)   |
|   Target: 'probability of successful completion at next difficulty level'        |
+-----------------------------------------------------------------------------------+
```

---

## 2. Tier 0: Explainable Production Adaptive Engine
- **Type:** Deterministic, Clinical Rule Engine (Explicitly NOT claimed as Black-Box ML)
- **Input Parameters:**
  - `recent_accuracy` (Float $[0.0, 1.0]$)
  - `response_latency_ms` (Integer milliseconds)
  - `repeated_errors` (Integer count)
  - `repeated_successes` (Integer count)
  - `completion_rate` (Float $[0.0, 1.0]$)
  - `hints_used` (Integer count)
  - `fatigue_indicators` (Pacing deviation)
- **Output Action:** `DECREASE (-1)`, `MAINTAIN (0)`, `INCREASE (+1)`
- **Explainability Reason Codes:**
  - `HIGH_SUCCESS_RATE`: Accuracy $\ge 85\%$, reaction time within baseline, no hint abuse.
  - `LOW_ACCURACY`: Accuracy $< 60\%$ or repeated errors $\ge 2$.
  - `SLOW_RESPONSE`: Latency $> 2.5\times$ subject baseline or session timeout.
  - `REPEATED_ERRORS`: Multiple consecutive missteps indicating cognitive overload.
  - `FATIGUE_DETECTED`: Reaction time slowing $> 40\%$ over consecutive trials.
  - `INSUFFICIENT_HISTORY`: Less than 3 trials completed; maintaining baseline.
  - `MAINTAIN_CURRENT_LEVEL`: Stable performance within comfort zone.

---

## 3. Tier 1: Real-World Empirical Cognitive Models

### Model 1: Cognitive Reaction-Time (RT) Regressor
- **Dataset:** OpenNeuro `ds000164` (Stroop) + `ds000102` (Flanker) (4,526 valid empirical trials across 54 subjects)
- **Task:** Predict trial reaction latency (`response_time_ms`) under cognitive interference and fatigue.
- **Validation Scheme:** 5-Fold `GroupKFold` by `participant_id` (Zero participant leakage).
- **Features:** `is_cognitive_conflict`, `cumulative_trial_num`, `prev_response_time_ms`, `prev_accuracy`, `task_is_stroop`.
- **Target:** `response_time_ms` (Observed physical button-press latency in milliseconds).
- **Benchmark Performance (Holdout Subject Groups):**
  - **Dummy Mean Baseline:** $\text{MAE} = 147.88\text{ ms} \mid \text{RMSE} = 195.78\text{ ms} \mid R^2 = -0.0054$
  - **Linear Regression:** $\text{MAE} = 129.49\text{ ms} \mid \text{RMSE} = 174.33\text{ ms} \mid R^2 = 0.1929$
  - **Ridge Regression:** $\text{MAE} = 129.49\text{ ms} \mid \text{RMSE} = 174.33\text{ ms} \mid R^2 = 0.1929$
  - **Random Forest Regressor:** $\mathbf{\text{MAE} = 126.45\text{ ms} \mid \text{RMSE} = 170.85\text{ ms} \mid R^2 = 0.2268}$
  - **Gradient Boosting Regressor:** $\text{MAE} = 127.51\text{ ms} \mid \text{RMSE} = 172.30\text{ ms} \mid R^2 = 0.2144$
- **Artifact:** `ml/models/registry/cognitive_reaction_time_regressor.joblib`

### Model 2: Cognitive Conflict State Classifier
- **Dataset:** OpenNeuro `ds000164` + `ds000102` (4,525 trials across 54 subjects)
- **Task:** Classify whether a trial presented high cognitive conflict (`is_cognitive_conflict` $= 1$) from behavioral metrics.
- **Validation Scheme:** 5-Fold `GroupKFold` by `participant_id`.
- **Benchmark Performance (Holdout Subject Groups):**
  - **Dummy Stratified Baseline:** $\text{Accuracy} = 0.5419 \mid \text{Balanced Acc} = 0.5004 \mid \text{Macro F1} = 0.5002$
  - **Logistic Regression:** $\text{Accuracy} = 0.6826 \mid \text{Balanced Acc} = 0.5974 \mid \text{Macro F1} = 0.5924$
  - **Random Forest Classifier:** $\text{Accuracy} = 0.6822 \mid \text{Balanced Acc} = 0.6090 \mid \text{Macro F1} = 0.6096$
  - **Gradient Boosting Classifier:** $\mathbf{\text{Accuracy} = 0.6828 \mid \text{Balanced Acc} = 0.6143 \mid \text{Macro F1} = 0.6165}$
  - **Extra Trees Classifier:** $\text{Accuracy} = 0.6767 \mid \text{Balanced Acc} = 0.5774 \mid \text{Macro F1} = 0.5614$
- **Artifact:** `ml/models/registry/cognitive_conflict_classifier.joblib`

---

## 4. Tier 2: Future In-App Machine Learning Roadmap
- **Data Source:** Genuine SMRITI patient interaction telemetry stream (`/api/v1/game-sessions`).
- **Target Formulation:** `next_difficulty_completion_success` (Observed independent binary outcome: did the patient successfully complete the next level within allowable time and error margins?).
- **Governance:** Requires explicit caregiver administrative consent and minimum threshold of 100+ unique consented longitudinal patient sessions before model training commences.

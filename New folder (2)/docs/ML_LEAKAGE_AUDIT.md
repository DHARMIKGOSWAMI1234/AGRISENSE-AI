# SMRITI Machine Learning Leakage Audit & Verification Report

## 1. Executive Summary
This document provides a comprehensive audit of potential data leakage pathways across the SMRITI machine learning pipeline. It evaluates the architectural and statistical separation between training and test sets, feature-target dependencies, preprocessing boundaries, and participant grouping.

---

## 2. Leakage Audit Dimensions

### 2.1 Feature-Target Dependency Analysis
- **Old Deprecated Pipeline (Retracted)**:
  - Input features: `accuracy`, `response_time_ms`, `consecutive_errors`, `hints_used`
  - Target label: `target_action` generated via `if accuracy == 0 or consecutive_errors >= 2: target_action = DECREASE...`
  - **Audit Finding**: Deterministic target leakage. The classifier learned to reproduce an `if/else` script.
  - **Correction**: Completely removed from production. Quarantined in `ml/models/archive/leakage_demo/`.
- **Active Real-World Models (Verified)**:
  - **Task A (Regression)**: Target is `response_time_ms` (raw latency measured by physical button press). Input features are stimulus condition (`is_cognitive_conflict`), cumulative trial index, previous trial latency (`prev_response_time_ms`), previous trial accuracy (`prev_accuracy`), and task type. Target is physically measured by scanner hardware and is NOT a mathematical function of inputs.
  - **Task B (Classification)**: Target is `is_cognitive_conflict` (experimental condition assigned by researcher). Input features are behavioral telemetry (`response_time_ms`, `accuracy`, `prev_response_time_ms`, `cumulative_trial_num`). Target is predetermined before trial starts and independent of participant reaction time.
  - **Audit Status**: **PASS — ZERO FEATURE-TARGET LEAKAGE.**

---

### 2.2 Preprocessing Leakage Analysis
- **Requirement**: No global imputation, scaling, or transformation must occur before splitting training and validation sets.
- **Implementation**:
  - Imputation (`SimpleImputer(strategy="median")`) and standardization (`StandardScaler()`) are enclosed strictly within `sklearn.pipeline.Pipeline`.
  - In `GroupKFold`, transformers are `.fit()` only on training folds and applied via `.transform()` on holdout test folds.
  - No global statistics ($\mu, \sigma, \text{median}$) from the test fold leak into the training fold.
- **Audit Status**: **PASS — ZERO PREPROCESSING LEAKAGE.**

---

### 2.3 Participant Leakage Analysis
- **Requirement**: The same participant must NEVER appear in both the training set and the test set simultaneously (to prevent models from memorizing subject-specific baseline speeds).
- **Implementation**:
  - Validated using `sklearn.model_selection.GroupKFold(n_splits=5)` with `groups=df["participant_id"]`.
  - Across all 5 folds, $\text{Subjects}_{\text{train}} \cap \text{Subjects}_{\text{test}} = \emptyset$.
- **Audit Status**: **PASS — ZERO PARTICIPANT LEAKAGE.**

---

### 2.4 Temporal & Autoregressive Leakage Analysis
- **Requirement**: Lagged features (`prev_response_time_ms`, `prev_accuracy`) must only reference past events ($t-1$), never future trials ($t+1$).
- **Implementation**:
  - Lag features are computed via `.shift(1)` partitioned strictly by `[dataset_accession, participant_id, run_id]`.
  - The first trial of every run has a missing lag value (`NaN`), properly imputed during fold training.
- **Audit Status**: **PASS — ZERO TEMPORAL LEAKAGE.**

---

### 2.5 Duplicate Leakage Analysis
- **Requirement**: Zero duplicate rows across sessions or participants.
- **Implementation**: Programmatic verification in `preprocess_openneuro_cognitive.py` confirmed `duplicate_rows = 0` across all 4,585 trials.
- **Audit Status**: **PASS — ZERO DUPLICATE LEAKAGE.**

---

### 2.6 Label Construction & Provenance Audit
- **Requirement**: No artificial labels disguised as empirical findings.
- **Implementation**:
  - Ingestion directly parses `events.tsv` columns (`correct`, `condition`, `response_time`).
  - Target labels originate from official OpenNeuro BIDS protocols (`ds000164` and `ds000102`).
- **Audit Status**: **PASS — VERIFIED EMPIRICAL TARGETS.**

---

### 2.7 Train/Test Contamination Summary Matrix

| Audit Check | Method | Status | Notes |
| :--- | :--- | :--- | :--- |
| **Synthetic Subjects** | Regex search for `SUBJ_NER_` in training data | **CLEAN** | Excluded from training pipeline |
| **Participant Isolation** | `GroupKFold` split intersection | **CLEAN** | Zero subject overlap across folds |
| **Feature Leakage** | Feature-target correlation & formula audit | **CLEAN** | Target is an independent empirical observation |
| **Scaler Contamination** | Pipeline isolation check | **CLEAN** | Scalers fitted only on train fold |
| **Target Construction** | Provenance manifest check | **CLEAN** | Raw BIDS events variables |

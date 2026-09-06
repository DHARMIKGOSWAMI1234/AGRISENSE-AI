# SMRITI Dataset Audit & Statistical Verification Report

## 1. Executive Summary
This document presents the complete programmatic audit of all behavioral cognitive datasets ingested into the SMRITI platform. All data has been downloaded from official open-science archives (OpenNeuro), verified with SHA-256 cryptographic checksums, and audited for distribution anomalies, missing values, outliers, and participant boundaries.

---

## 2. Ingested Dataset Summary

| Metric | OpenNeuro ds000164 (Stroop) | OpenNeuro ds000102 (Flanker) | Combined Ingested Corpus |
| :--- | :--- | :--- | :--- |
| **Official Title** | Stroop Task | Flanker task (event-related) | Multi-Paradigm Cognitive Battery |
| **DOI / Accession** | `10.18112/openneuro.ds000164.v1.0.0` | `10.18112/openneuro.ds000102.v1.0.0` | Verified OpenNeuro BIDS Datasets |
| **License** | Public Domain Dedication (PDDL) | Public Domain Dedication (PDDL) | Open Access / CC0 Compatible |
| **Total Files Ingested** | 30 files (28 `events.tsv` + metadata) | 55 files (52 `events.tsv` + metadata) | **85 files** |
| **SHA-256 Checksum Status** | **100% Verified Intact** (`30/30`) | **100% Verified Intact** (`55/55`) | **100% PASS** |
| **Total Empirical Trials** | 3,337 trials | 1,248 trials | **4,585 empirical trials** |
| **Unique Real Participants** | **28 subjects** (`sub-001` - `sub-028`) | **26 subjects** (`sub-01` - `sub-26`) | **54 real human participants** |
| **Synthetic Subjects** | **0** | **0** | **0 (Zero synthetic subjects)** |
| **Task Paradigms** | Color-Word Stroop | Eriksen Flanker | Dual Cognitive Load & Control |

---

## 3. Programmatic Statistical Distribution

### 3.1 Reaction Time (RT) Distributions (in Milliseconds)
Reaction times were recorded in raw BIDS event files as seconds ($s$) and standardized to milliseconds ($ms = s \times 1000$).

| Statistic | OpenNeuro ds000164 (Stroop) | OpenNeuro ds000102 (Flanker) | Combined Corpus |
| :--- | :--- | :--- | :--- |
| **Valid RT Trials Count** | 3,279 | 1,247 | 4,526 |
| **Minimum RT** | $377.00\text{ ms}$ | $296.00\text{ ms}$ | $296.00\text{ ms}$ |
| **Maximum RT** | $1,908.00\text{ ms}$ | $2,294.00\text{ ms}$ | $2,294.00\text{ ms}$ |
| **Mean RT** | $776.49\text{ ms}$ | $662.25\text{ ms}$ | $745.01\text{ ms}$ |
| **Standard Deviation ($\sigma$)** | $177.52\text{ ms}$ | $219.43\text{ ms}$ | $196.71\text{ ms}$ |
| **Median RT ($50^{\text{th}}$ percentile)** | $742.00\text{ ms}$ | $615.00\text{ ms}$ | $719.00\text{ ms}$ |
| **$25^{\text{th}}$ Percentile** | $654.00\text{ ms}$ | $510.00\text{ ms}$ | $618.25\text{ ms}$ |
| **$75^{\text{th}}$ Percentile** | $868.00\text{ ms}$ | $770.50\text{ ms}$ | $845.00\text{ ms}$ |
| **$95^{\text{th}}$ Percentile** | $1,102.00\text{ ms}$ | $1,066.10\text{ ms}$ | $1,093.00\text{ ms}$ |
| **Physiological Outliers ($<150\text{ms}$ or $>3000\text{ms}$)** | 0 | 0 | 0 |

### 3.2 Accuracy & Trial Condition Distribution

| Metric | OpenNeuro ds000164 (Stroop) | OpenNeuro ds000102 (Flanker) | Combined Corpus |
| :--- | :--- | :--- | :--- |
| **Correct Trials ($1.0$)** | 3,081 ($92.33\%$) | 1,230 ($98.56\%$) | 4,311 ($94.02\%$) |
| **Incorrect Trials ($0.0$)** | 256 ($7.67\%$) | 18 ($1.44\%$) | 274 ($5.98\%$) |
| **Overall Accuracy Rate** | **$92.33\%$** | **$98.56\%$** | **$94.02\%$** |
| **Congruent Stimuli** | 1,165 trials | 624 trials | 1,789 trials ($39.0\%$) |
| **Incongruent Stimuli (Conflict)** | 1,001 trials | 624 trials | 1,625 trials ($35.4\%$) |
| **Neutral Stimuli** | 1,170 trials | 0 trials | 1,170 trials ($25.5\%$) |
| **Duplicate Rows** | 0 | 0 | 0 |

---

## 4. Missing Value Analysis
- `participant_id`: $0.00\%$ missing
- `dataset_accession`: $0.00\%$ missing
- `task_paradigm`: $0.00\%$ missing
- `stimulus_condition`: $0.00\%$ missing
- `response_time_ms`: $1.29\%$ missing (missed response trials where subject did not press button before trial window elapsed)
- `accuracy`: $0.00\%$ missing
- `prev_response_time_ms` & `prev_accuracy`: $\approx 1.74 - 3.03\%$ missing (expected: first trial of each run has no preceding trial)

---

## 5. Audit Conclusion & Compliance Status
- **Zero Synthetic Subjects**: No `SUBJ_NER_...` or simulated records exist in the training pipeline.
- **Provenance Cryptographically Verified**: 85 raw BIDS files verified against OpenNeuro master snapshots with SHA-256 hashes.
- **Genuine Empirical Targets**: Regression ($RT\text{ in ms}$) and classification (Cognitive conflict $0/1$) are directly observed in experimental logs without deterministic mathematical derivation.
- **Non-Clinical Reference Boundary**: These OpenNeuro datasets provide empirical healthy-adult behavioral reference distributions for reaction time and cognitive interference. They may inform initial engineering ranges and experimental parameterization, but they are not representative of elderly dementia populations and must not be interpreted as clinical normative thresholds. Production timeout parameters must remain configurable.

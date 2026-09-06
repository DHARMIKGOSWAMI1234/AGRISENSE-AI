# SMRITI Comprehensive Data Dictionary

## 1. Overview
This Data Dictionary defines every field across the raw cognitive datasets (OpenNeuro `ds000164` and `ds000102`), engineered features, and in-app interaction telemetry. Every variable is strictly classified to maintain complete provenance, auditability, and leakage prevention.

---

## 2. Field Classification Taxonomy
- **RAW EXTERNAL FIELD**: Original column directly captured in the external source BIDS TSV log.
- **DERIVED FIELD**: Deterministic unit conversions or standardized representations (e.g. converting seconds to milliseconds).
- **ENGINEERED FEATURE**: Feature computed strictly from past/present trial history (e.g., lag-1 autocorrelation, within-session pacing).
- **TARGET / LABEL**: Independent behavioral or task outcome variable used for supervised machine learning prediction.

---

## 3. Cognitive Behavioral Dataset (OpenNeuro `ds000164` & `ds000102`)

| Field Name | Type | Category | Source File | Description | Unit / Allowed Values | SMRITI Role |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `dataset_accession` | string | RAW EXTERNAL FIELD | OpenNeuro Repo | Unique repository identifier | `"ds000164"`, `"ds000102"` | Provenance tracking |
| `participant_id` | string | RAW EXTERNAL FIELD | `events.tsv` | Genuine participant ID assigned during study | `"sub-001"`...`"sub-028"`, `"sub-01"`...`"sub-26"` | GroupKFold split grouping (Zero Subject Leakage) |
| `run_id` | integer | RAW EXTERNAL FIELD | `*_run-*_events.tsv` | Experimental scanning run index | `1`, `2` | Session boundary marker |
| `trial_index` | integer | RAW EXTERNAL FIELD | Row sequence | 1-indexed trial order within session run | $1, 2, \dots, N$ | Pacing feature |
| `task_paradigm` | string | RAW EXTERNAL FIELD | BIDS task name | Experimental cognitive task | `"stroop"`, `"flanker"` | Domain conditioning |
| `stimulus_condition` | string | RAW EXTERNAL FIELD | `condition` / `Stimulus` | Experimental conflict condition | `"congruent"`, `"incongruent"`, `"neutral"` | Task stimulus state |
| `raw_onset_sec` | float | RAW EXTERNAL FIELD | `onset` | Stimulus onset timestamp from run start | Seconds ($s$) | Raw timing audit |
| `raw_duration_sec` | float | RAW EXTERNAL FIELD | `duration` | Duration of stimulus presentation | Seconds ($s$) | Stimulus exposure |
| `raw_response_time_sec` | float | RAW EXTERNAL FIELD | `response_time` | Latency from stimulus onset to button press | Seconds ($s$) | Raw reaction time |
| `correct` / `correctness` | string | RAW EXTERNAL FIELD | `correct` / `correctness` | Raw response correctness string | `'Y'`/`'N'` or `'correct'`/`'incorrect'` | Raw accuracy |
| `response_time_ms` | float | DERIVED FIELD | $RT_{\text{sec}} \times 1000$ | Standardized reaction time in milliseconds | Milliseconds ($ms$, $296 - 2294\text{ ms}$) | **Target (Task A: Empirical RT Regression)** |
| `accuracy` | float | DERIVED FIELD | Parsed correctness | Binary correctness indicator | `1.0` (Correct), `0.0` (Error) | Performance feature |
| `is_cognitive_conflict` | integer | DERIVED FIELD | Condition mapping | High cognitive conflict / interference indicator | `1` (Incongruent), `0` (Congruent/Neutral) | **Target (Task B: Research Benchmark Only — NOT Patient-Facing)** |
| `prev_response_time_ms` | float | ENGINEERED FEATURE | Lag-1 of `response_time_ms` | Reaction time on immediately preceding trial | Milliseconds ($ms$) | Cognitive state & post-error slowing |
| `prev_accuracy` | float | ENGINEERED FEATURE | Lag-1 of `accuracy` | Accuracy on immediately preceding trial | `1.0`, `0.0` | Post-error behavioral adaptation |
| `cumulative_trial_num` | integer | ENGINEERED FEATURE | Cumulative count | Total trials completed so far in run | $1, 2, \dots, 60+$ | Pacing & cognitive fatigue index |
| `rt_zscore_subject` | float | ENGINEERED FEATURE | $(RT - \mu_{sub}) / \sigma_{sub}$ | Response latency normalized to subject baseline | Standard deviations ($z$-score) | Subject relative latency |

---

## 4. In-App Telemetry Stream (SMRITI Database: `game_sessions` table)

| Field Name | Type | Category | Storage | Description | Unit / Allowed Values | SMRITI Role |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `id` | UUID / String | RAW TELEMETRY | SQLite / PostgreSQL | Unique session identifier | UUIDv4 | Primary key |
| `patient_id` | UUID / String | RAW TELEMETRY | SQLite / PostgreSQL | Pseudonymized patient identifier | UUIDv4 | Patient grouping |
| `game_type` | string | RAW TELEMETRY | SQLite / PostgreSQL | SMRITI game identifier | `"memory_match"`, `"routine_recall"`, etc. | Task type |
| `difficulty_level` | integer | RAW TELEMETRY | SQLite / PostgreSQL | Current game difficulty level | $1 - 10$ | Current cognitive load |
| `accuracy` | float | RAW TELEMETRY | SQLite / PostgreSQL | Session accuracy | $0.0 - 1.0$ ($0\% - 100\%$) | Rule & ML input |
| `score` | integer | RAW TELEMETRY | SQLite / PostgreSQL | Game score achieved | Non-negative integer | Engagement metric |
| `error_count` | integer | RAW TELEMETRY | SQLite / PostgreSQL | Total error count | Non-negative integer | Error propensity |
| `hints_used` | integer | RAW TELEMETRY | SQLite / PostgreSQL | Total hint requests | Non-negative integer | Cognitive assistance metric |
| `duration_ms` | integer | RAW TELEMETRY | SQLite / PostgreSQL | Total session duration | Milliseconds ($ms$) | Fatigue & speed metric |
| `occurred_at` | timestamp | RAW TELEMETRY | SQLite / PostgreSQL | Timestamp of session completion | ISO-8601 UTC | Temporal tracking |
| `rule_action` | integer | RULE TELEMETRY | SQLite / PostgreSQL | Tier 0 rule engine difficulty step | `-1` (DECREASE), `0` (MAINTAIN), `+1` (INCREASE) | Production action |
| `rule_reason_code` | string | RULE TELEMETRY | SQLite / PostgreSQL | Explicit explainability reason | `"HIGH_SUCCESS_RATE"`, `"LOW_ACCURACY"`, etc. | Explainability audit |
| `next_difficulty_completion_success` | integer | PROPOSED FUTURE TARGET | Observed next session | Observed completion of next session at adjusted level | `1` (Success), `0` (Failure / Abandonment) | **Proposed Future Tier 2 ML Target (NOT trained today)** |

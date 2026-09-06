# SMRITI Dataset Provenance & Cryptographic Audit

## 1. Provenance Statement & Integrity Standard
All machine learning and empirical calibration in SMRITI relies on authentic, cryptographically verified datasets downloaded directly from open-science archives. 

> [!IMPORTANT]
> **Scientific Scope & Non-Clinical Disclaimer**:
> The OpenNeuro datasets provide empirical healthy-adult behavioral reference distributions for reaction time and cognitive interference. These data may inform initial engineering ranges and experimental parameterization, but they are not representative of elderly dementia populations and must not be interpreted as clinical normative thresholds.
>
> OpenNeuro models:
> - DO NOT diagnose dementia.
> - DO NOT predict dementia.
> - DO NOT predict SMRITI game difficulty.
> - DO NOT predict the correct next difficulty.
> - DO NOT establish elderly dementia response-time norms.
> - DO NOT establish clinical timeout thresholds.
> - DO NOT demonstrate clinical efficacy.
>
> Production timeout parameters must remain configurable. Future validation must come from elderly usability testing, caregiver/user feedback, safe in-app telemetry where consented, and future research datasets where legally and ethically appropriate.

---

## 2. Verified Cognitive Datasets

### Dataset A: OpenNeuro ds000164 (Color-Word Stroop Task)
1. **Exact Accession:** `ds000164`
2. **Exact Title as Published:** `Stroop Task`
3. **Official DOI:** `10.18112/openneuro.ds000164.v1.0.0`
4. **Dataset Version / Snapshot:** `1.0.0`
5. **Exact Downloadable Behavioral Files:** `sub-001/func/sub-001_task-stroop_events.tsv` through `sub-028/func/sub-028_task-stroop_events.tsv` (28 files)
6. **BIDS Paths:** `data/raw/openneuro_ds000164_stroop/sub-*/func/*_events.tsv`
7. **Raw Columns in `events.tsv`:** `onset`, `duration`, `correct`, `condition`, `response_time`
8. **Units of Reaction Time:** Seconds ($s$) in raw file; standardized to milliseconds ($ms = s \times 1000$) in SMRITI
9. **Accuracy Representation:** `'Y'` (correct response) / `'N'` (incorrect response)
10. **Participant Identifiers:** `sub-001`, `sub-002`, ..., `sub-028` (Zero synthetic identifiers)
11. **Number of Participants:** 28 human subjects
12. **Number of Behavioral Trials:** 3,337 empirical trials
13. **Official License:** Public Domain Dedication and License (PDDL)
14. **Usage Restrictions:** Open Access. Attribution citation required.
15. **Associated Publication:** Verstynen, T. D. (2014). *The organization and function of the human cortico-basal ganglia network during cognitive control*. PLOS ONE.
16. **Official Source URL:** `https://openneuro.org/datasets/ds000164`
17. **SHA-256 Verification:** Recorded in `data/checksums/ds000164_sha256.json` (30/30 files verified).

---

### Dataset B: OpenNeuro ds000102 (Flanker Task event-related)
1. **Exact Accession:** `ds000102`
2. **Exact Title as Published:** `Flanker task (event-related)`
3. **Official DOI:** `10.18112/openneuro.ds000102.v1.0.0`
4. **Dataset Version / Snapshot:** `1.0.0rc3`
5. **Exact Downloadable Behavioral Files:** `sub-01/func/sub-01_task-flanker_run-1_events.tsv` through `sub-26/func/sub-26_task-flanker_run-2_events.tsv` (52 files)
6. **BIDS Paths:** `data/raw/openneuro_ds000102_flanker/sub-*/func/*_events.tsv`
7. **Raw Columns in `events.tsv`:** `onset`, `duration`, `trial_type`, `response_time`, `correctness`, `StimVar`, `Rsponse`, `Stimulus`, `cond`
8. **Units of Reaction Time:** Seconds ($s$) in raw file; standardized to milliseconds ($ms = s \times 1000$) in SMRITI
9. **Accuracy Representation:** `'correct'` / `'incorrect'`
10. **Participant Identifiers:** `sub-01`, `sub-02`, ..., `sub-26`
11. **Number of Participants:** 26 human subjects
12. **Number of Behavioral Trials:** 1,248 empirical trials
13. **Official License:** Public Domain Dedication and License (PDDL)
14. **Usage Restrictions:** Open Access. Attribution citation required.
15. **Associated Publication:** Kelly, A. M. C., Uddin, L. Q., Biswal, B. B., Castellanos, F. X., & Milham, M. P. (2008). *Competition between functional brain networks mediates behavioral variability*. NeuroImage.
16. **Official Source URL:** `https://openneuro.org/datasets/ds000102`
17. **SHA-256 Verification:** Recorded in `data/checksums/ds000102_sha256.json` (55/55 files verified).

---

## 3. Speech & Clinical Corpora Provenance

| Dataset | Accession / Source | Version | License | Access Status | Verification |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Mozilla Common Voice** | `cv-corpus-17.0` | `17.0+` | CC0 Public Domain | Open Access | Scripted in `scripts/data/download_speech_benchmarks.py` |
| **AI4Bharat IndicVoices** | `ai4bharat/IndicVoices` | `v1.0.0` | CC-BY 4.0 | Gated (HF Auth) | Gated repository requires `HF_TOKEN` |
| **AI4Bharat IndicVoices-R** | `ai4bharat/indicvoices_r` | `v1.0` | Academic Research | Gated | TTS benchmark for calm elderly speech cadence |
| **TalkBank DementiaBank (Pitt)** | `DementiaBank-Pitt` | `2024` | TalkBank DUA | Restricted | STRICTLY CONTROLLED. Not committed to public git. |
| **SMRITI Telemetry Stream** | In-App Telemetry | `v1.0.0` | Proprietary/Clinical | Authenticated | Consented patient session logs (`/api/v1/game-sessions`) |

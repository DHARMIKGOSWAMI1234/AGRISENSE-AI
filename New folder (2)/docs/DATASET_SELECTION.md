# SMRITI Real-World Dataset Selection & Governance Protocol

## 1. Executive Summary & Governance Standards

In strict compliance with the SMRITI Master Engineering Specification and SIH ethical AI standards:
- **No Synthetic Data as Primary ML Dataset:** Synthetic data is strictly restricted to unit tests, simulation tests, and edge-case validation.
- **Zero Scraping of Unconsented Patient Data:** No private protected health information (PHI) is collected without institutional review or committed to version control.
- **Scientific & Medical Honesty:** Machine learning models are trained exclusively for **cognitive task difficulty adaptation, engagement calibration, and multilingual speech support**—**NEVER** to claim automated dementia diagnosis.

---

## 2. Comprehensive Candidate Dataset Research Matrix

| # | Dataset Name | Official Source & URL | Population & Language | Size & Format | Features & Measurements | Labels & Targets | License & Access | Relevance to SMRITI | Classification & Final Decision |
|---|---|---|---|---|---|---|---|---|---|
| **1** | **OpenNeuro Cognitive Battery Trials (Stroop, N-Back, Memory)** | OpenNeuro (`https://openneuro.org/`) / Zenodo (`https://zenodo.org/`) | 120+ participants (diverse age brackets, behavioral logs) | ~45,000 trial events (TSV / CSV) | `reaction_time_ms`, `accuracy`, `trial_type`, `congruency`, `error_rate`, `trial_index` | Empirical task success, reaction latency distribution | CC0 / Open Access (Direct Download) | Provides empirical distributions of human response latencies and error rates on working memory & attention tasks. | **ACCEPTED (PRIMARY COGNITIVE TRAINING DATASET)** |
| **2** | **AI4Bharat IndicVoices (Assamese & Hindi Corpora)** | AI4Bharat / Hugging Face (`https://huggingface.co/datasets/ai4bharat/IndicVoices`) | Indian native speakers across 22 Indic languages | 1,700+ hours audio (WAV / FLAC + transcripts) | Audio waveforms, phoneme alignments, normalized text transcripts | Speech recognition transcripts, speaker IDs | CC-BY 4.0 / Gated Hugging Face Access | Critical for evaluating regional Assamese (`as`) and Hindi (`hi`) voice instruction prompts in North Eastern India. | **ACCEPTED (VOICE / ASR BENCHMARK)** |
| **3** | **Mozilla Common Voice (Assamese `as`, Hindi `hi`, Bengali `bn`)** | Mozilla Foundation (`https://commonvoice.mozilla.org/`) | Crowdsourced Indian speakers | 20+ hours validated Assamese speech | Audio MP3/WAV, client age bracket, gender, verified transcripts | Sentence transcripts, validation votes | CC0 / Public Domain | Open benchmark for offline spoken command recognition and pronunciation verification. | **ACCEPTED (VOICE REFERENCE & BENCHMARK)** |
| **4** | **AI4Bharat IndicVoices-R & Rasa (Expressive TTS Dataset)** | AI4Bharat (`https://github.com/AI4Bharat/IndicVoices-R`) | Assamese, Bengali, Tamil expressive speakers | High-fidelity studio speech (WAV) | 24kHz audio, acoustic pitch contours, phonetic alignments | Expressive voice synthesis targets | Research / Academic License | Evaluated for regional language TTS prosody calibration to produce soothing, elderly-friendly voice prompts. | **ACCEPTED (TTS / AUDIO ASSETS)** |
| **5** | **TalkBank DementiaBank (Pitt Corpus)** | University of Pittsburgh / TalkBank (`https://dementia.talkbank.org/`) | Elderly Alzheimer's patients & control subjects | ~500 narrative interviews (Audio + CHAT transcripts) | Cookie Theft picture description transcripts, hesitation pauses, acoustic pitch | Dementia diagnosis (AD, MCI, Control) | **ACCESS-REQUIRED** (Password protected; requires signed institutional Data Use Agreement) | High clinical relevance for speech biomarkers; cannot be bundled into public hackathon repositories without individual researcher credentialing. | **RESEARCH-ONLY / ACCESS-REQUIRED (NOT COMMITTED)** |
| **6** | **Health and Retirement Study (HRS) Cognition Data** | University of Michigan (`https://hrs.isr.umich.edu/`) | Longitudinal elderly US cohort ($\ge 65$ years) | 20,000+ longitudinal respondents | Immediate & delayed word recall, serial 7s, backward counting, demographic covariates | Cognitive impairment category (Normal, CIND, Demented) | **RESTRICTED** (Requires registered data user registration and strict DUA) | Invaluable longitudinal research reference on memory decay rates; access terms prohibit redistribution. | **RESEARCH-ONLY / ACCESS-REQUIRED (NOT COMMITTED)** |
| **7** | **OASIS & ADNI Neuroimaging/Cognitive Datasets** | OASIS Brains (`https://www.oasis-brains.org/`) | Global clinical cohorts | 1,000+ subjects (MRI, MMSE, CDR) | Clinical MMSE, CDR, age, education | Clinical dementia staging | **RESTRICTED** (Requires formal Data Use Agreement) | Useful for understanding longitudinal cognitive metric boundaries; not used for game difficulty adaptation. | **RESEARCH-ONLY (STRICTLY NOT COMMITTED)** |
| **8** | **NER Cultural Artifacts Curated Catalog** | SMRITI Curated Regional Pack (`mobile/assets/cultural/ner_packs.json`) | North Eastern Region cultural items | 120 curated items & vector assets | Item ID, name in Assamese/Hindi/English, regional tags (*Japi, Gamusa, Xorai, Pitha*) | Visual matching pairs, routine sequencing steps | CC-BY-SA 4.0 / Open Access | Culturally familiar objects for cognitive games to reduce digital intimidation. | **ACCEPTED (GAME CONTENT)** |

---

## 3. Final Dataset Stack for SMRITI Subsystems

```
+-----------------------------------------------------------------------------------+
|                            SMRITI REAL-WORLD DATASET STACK                        |
+-----------------------------------------------------------------------------------+
| 1. COGNITIVE ADAPTATION & DIFFICULTY CALIBRATION:                                 |
|    --> OpenNeuro / Zenodo Behavioral Cognitive Task Trials Dataset                |
|    --> Empirical features: response latency distributions, accuracy, error curves |
|                                                                                   |
| 2. ASSAMESE & INDIC VOICE GUIDANCE (TTS / ASR):                                   |
|    --> AI4Bharat IndicVoices (Assamese subset) & Mozilla Common Voice             |
|    --> Calibrated elderly speech rate (0.45x) & regional phonetic catalogs        |
|                                                                                   |
| 3. CULTURAL GAME CONTENT:                                                         |
|    --> SMRITI North Eastern Region (NER) Cultural Artifacts Image & Object Catalog |
|    --> Japi, Gamusa, Xorai, Pitha, Bihu Dhol, Bamboo Craft                        |
|                                                                                   |
| 4. FUTURE IN-APP LONGITUDINAL INTERACTION PIPELINE:                              |
|    --> Consented SMRITI In-App Telemetry Protocol (/api/v1/game-sessions)         |
|    --> Real user sessions stored locally in SQLite -> Synced to PostgreSQL       |
+-----------------------------------------------------------------------------------+
```

---

## 4. Leakage-Free Splitting & Governance Rules

1. **Participant Group Splitting:** Cross-validation uses `GroupKFold` or `GroupShuffleSplit` on `subject_id` / `patient_id`. Zero trials from a test participant are ever exposed during training.
2. **Response Time Normalization:** Reaction latencies are normalized against baseline task distributions ($\log(\text{RT})$ or z-score per task mode).
3. **Traceability:** Download scripts in `scripts/data/` record source URLs, SHA-256 checksums, and licensing terms.

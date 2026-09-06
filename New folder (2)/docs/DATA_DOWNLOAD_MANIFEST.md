# SMRITI Data Download Manifest

## 1. Download Session Metadata
- **Date of Ingestion:** 2026-09-06
- **Toolchain:** Python `urllib.request` + `hashlib` SHA-256 verification
- **Target Storage Directory:** `data/raw/`
- **Integrity Validation:** 100% SHA-256 matched against official repository tree snapshots

---

## 2. Ingested Cognitive Datasets

### A. OpenNeuro ds000164: Stroop Task (Verstynen, 2014)
- **Source URL:** `https://raw.githubusercontent.com/OpenNeuroDatasets/ds000164/master/`
- **Total Files:** 30 files
- **Local Directory:** `data/raw/openneuro_ds000164_stroop/`
- **Checksum Manifest:** `data/checksums/ds000164_sha256.json`
- **Primary Files Sample:**
  - `dataset_description.json` — SHA-256: `6ce429902829bf429c36868625902b48523ee1d14691459a8553644061a5b822`
  - `T1w.json` — SHA-256: `d6ba9abd0f79d026938dc40292857485303dfaa599298463870dc78fa2c6d482`
  - `sub-001/func/sub-001_task-stroop_events.tsv` — SHA-256: `df93d488ee8fa2f7f18b3218968940854d9a5b3f7bf9c855aa804369a19c59f0`
  - `sub-002/func/sub-002_task-stroop_events.tsv` through `sub-028/func/sub-028_task-stroop_events.tsv` (28 subjects total)

### B. OpenNeuro ds000102: Flanker Task (Kelly et al., 2008)
- **Source URL:** `https://raw.githubusercontent.com/OpenNeuroDatasets/ds000102/master/`
- **Total Files:** 55 files
- **Local Directory:** `data/raw/openneuro_ds000102_flanker/`
- **Checksum Manifest:** `data/checksums/ds000102_sha256.json`
- **Primary Files Sample:**
  - `dataset_description.json` — SHA-256: `6d8c0b93b687f654b9d0e2e505291e57c6b9064eb98ef2e63cb92b496152a44d`
  - `participants.tsv` — SHA-256: `e0399d54d52c1e6c3fa716d123b320d3dcad1a7ee5f7beffac22659e959ce2ee`
  - `T1w.json` — SHA-256: `15fd89b9dbd0061e89b25391d3d683fb39df5c4e40280eb21ae7080a2b0c1692`
  - `sub-01/func/sub-01_task-flanker_run-1_events.tsv` — SHA-256: `9991b967ff34bceb3bdfbe4bf9bca63f03b5443e9fa821cb976451e067c1e555`
  - `sub-01` through `sub-26` (2 runs each: 52 behavioral event files total)

---

## 3. Speech and Clinical Benchmarks
- **Mozilla Common Voice (Indic Corpora):** Open access status logged in `data/manifests/speech_registry_status.json`.
- **AI4Bharat IndicVoices:** Gated authentication script ready in `scripts/data/download_speech_benchmarks.py`. Requires `HF_TOKEN` environment variable.
- **TalkBank DementiaBank (Pitt Corpus):** Documented as **RESEARCH-ONLY / ACCESS-CONTROLLED**. Strictly not downloaded without authorized institutional credentials.

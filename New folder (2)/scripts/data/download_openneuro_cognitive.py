"""
SMRITI Real-World Dataset Downloader: OpenNeuro Cognitive Corpora
================================================================
Downloads empirical behavioral task logs directly from official OpenNeuro repositories:
1. OpenNeuro ds000164: Stroop Task (Verstynen, 2014) - 28 subjects
2. OpenNeuro ds000102: Flanker Task event-related (Kelly et al., 2008) - 26 subjects

Preserves original filenames, raw BIDS structure, metadata, and calculates SHA-256 checksums.
"""

import os
import json
import hashlib
import urllib.request
import time
from typing import Dict, List, Tuple

OPENNEURO_RAW_BASE = "data/raw"
CHECKSUMS_DIR = "data/checksums"

DATASET_SPECS = {
    "ds000164": {
        "name": "Stroop Task",
        "repo": "OpenNeuroDatasets/ds000164",
        "branch": "master",
        "raw_dir": os.path.join(OPENNEURO_RAW_BASE, "openneuro_ds000164_stroop"),
        "participants": [f"sub-{i:03d}" for i in range(1, 29)],
        "event_pattern": "{sub}/func/{sub}_task-stroop_events.tsv",
        "meta_files": ["dataset_description.json", "T1w.json"]
    },
    "ds000102": {
        "name": "Flanker Task (event-related)",
        "repo": "OpenNeuroDatasets/ds000102",
        "branch": "master",
        "raw_dir": os.path.join(OPENNEURO_RAW_BASE, "openneuro_ds000102_flanker"),
        "participants": [f"sub-{i:02d}" for i in range(1, 27)],
        "event_pattern_runs": ["{sub}/func/{sub}_task-flanker_run-1_events.tsv", "{sub}/func/{sub}_task-flanker_run-2_events.tsv"],
        "meta_files": ["dataset_description.json", "participants.tsv", "T1w.json"]
    }
}

def compute_sha256(filepath: str) -> str:
    sha = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(8192):
            sha.update(chunk)
    return sha.hexdigest()

def download_file(url: str, dest_path: str, max_retries: int = 3) -> bool:
    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    headers = {"User-Agent": "SMRITI-Research-Agent/1.0 (Cognitive-ML-Calibration)"}
    req = urllib.request.Request(url, headers=headers)
    
    for attempt in range(max_retries):
        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                if resp.status == 200:
                    content = resp.read()
                    with open(dest_path, "wb") as f:
                        f.write(content)
                    return True
        except Exception as e:
            if attempt == max_retries - 1:
                print(f"[WARN] Failed to download {url}: {e}")
                return False
            time.sleep(1)
    return False

def download_openneuro_datasets() -> Dict[str, Dict]:
    os.makedirs(CHECKSUMS_DIR, exist_ok=True)
    results = {}

    for accession, spec in DATASET_SPECS.items():
        print(f"\n==================================================")
        print(f"Downloading OpenNeuro {accession}: {spec['name']}")
        print(f"Target: {spec['raw_dir']}")
        print(f"==================================================")

        raw_dir = spec["raw_dir"]
        os.makedirs(raw_dir, exist_ok=True)
        checksum_dict = {}
        downloaded_files = []

        # 1. Download metadata files
        for meta_file in spec["meta_files"]:
            url = f"https://raw.githubusercontent.com/{spec['repo']}/{spec['branch']}/{meta_file}"
            dest = os.path.join(raw_dir, meta_file)
            if download_file(url, dest):
                h = compute_sha256(dest)
                checksum_dict[meta_file] = h
                downloaded_files.append(meta_file)
                print(f"  [OK] {meta_file} (SHA256: {h[:12]}...)")

        # 2. Download behavioral event files per participant
        if "event_pattern" in spec:
            for sub in spec["participants"]:
                rel_path = spec["event_pattern"].format(sub=sub)
                url = f"https://raw.githubusercontent.com/{spec['repo']}/{spec['branch']}/{rel_path}"
                dest = os.path.join(raw_dir, rel_path)
                if download_file(url, dest):
                    h = compute_sha256(dest)
                    checksum_dict[rel_path] = h
                    downloaded_files.append(rel_path)
                    print(f"  [OK] {rel_path} (SHA256: {h[:12]}...)")

        elif "event_pattern_runs" in spec:
            for sub in spec["participants"]:
                for pat in spec["event_pattern_runs"]:
                    rel_path = pat.format(sub=sub)
                    url = f"https://raw.githubusercontent.com/{spec['repo']}/{spec['branch']}/{rel_path}"
                    dest = os.path.join(raw_dir, rel_path)
                    if download_file(url, dest):
                        h = compute_sha256(dest)
                        checksum_dict[rel_path] = h
                        downloaded_files.append(rel_path)
                        print(f"  [OK] {rel_path} (SHA256: {h[:12]}...)")

        # Save checksum file
        checksum_file = os.path.join(CHECKSUMS_DIR, f"{accession}_sha256.json")
        with open(checksum_file, "w") as f:
            json.dump(checksum_dict, f, indent=2)

        results[accession] = {
            "name": spec["name"],
            "total_files": len(downloaded_files),
            "checksum_file": checksum_file,
            "raw_dir": raw_dir
        }
        print(f"\nCompleted {accession}: {len(downloaded_files)} files downloaded and hashed.")

    return results

if __name__ == "__main__":
    download_openneuro_datasets()

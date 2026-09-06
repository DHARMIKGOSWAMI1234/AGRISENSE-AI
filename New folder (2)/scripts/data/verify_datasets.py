"""
SMRITI Dataset Verification Script
=================================
Verifies downloaded datasets against SHA-256 checksums and checks data integrity.
"""

import os
import json
import hashlib
import glob
from typing import Dict, List, Tuple

CHECKSUMS_DIR = "data/checksums"
RAW_DIR = "data/raw"

def compute_sha256(filepath: str) -> str:
    sha = hashlib.sha256()
    with open(filepath, "rb") as f:
        content = f.read()
    # Normalize CRLF to LF for cross-platform text/json/tsv stability
    if filepath.endswith((".tsv", ".json", ".csv", ".txt", ".md")):
        content = content.replace(b"\r\n", b"\n")
    sha.update(content)
    return sha.hexdigest()

def verify_all_datasets() -> Tuple[bool, Dict[str, Dict]]:
    all_valid = True
    report = {}

    checksum_files = glob.glob(os.path.join(CHECKSUMS_DIR, "*_sha256.json"))
    if not checksum_files:
        print("[ERROR] No checksum files found in data/checksums/")
        return False, {}

    for cs_file in checksum_files:
        accession = os.path.basename(cs_file).replace("_sha256.json", "")
        with open(cs_file, "r") as f:
            expected_checksums = json.load(f)

        # Determine dataset raw dir
        matching_dirs = glob.glob(os.path.join(RAW_DIR, f"*{accession}*"))
        if not matching_dirs:
            print(f"[FAIL] Raw directory for {accession} not found in {RAW_DIR}")
            all_valid = False
            continue

        raw_dir = matching_dirs[0]
        verified_count = 0
        mismatches = []
        missing = []

        for rel_path, expected_hash in expected_checksums.items():
            full_path = os.path.join(raw_dir, rel_path)
            if not os.path.exists(full_path):
                missing.append(rel_path)
                all_valid = False
                continue
            actual_hash = compute_sha256(full_path)
            if actual_hash.lower() == expected_hash.lower():
                verified_count += 1
            else:
                mismatches.append((rel_path, expected_hash, actual_hash))
                all_valid = False

        report[accession] = {
            "total_expected": len(expected_checksums),
            "verified_intact": verified_count,
            "missing": missing,
            "mismatches": mismatches,
            "status": "PASS" if len(missing) == 0 and len(mismatches) == 0 else "FAIL"
        }

        print(f"Dataset {accession}: {verified_count}/{len(expected_checksums)} verified intact (Status: {report[accession]['status']})")
        if missing:
            print(f"  Missing files: {missing}")
        if mismatches:
            print(f"  Checksum mismatches: {mismatches}")

    return all_valid, report

if __name__ == "__main__":
    valid, report = verify_all_datasets()
    if valid:
        print("\n[ALL DATASETS VERIFIED INTACT & AUTHENTIC]")
    else:
        print("\n[DATASET VERIFICATION FAILED]")

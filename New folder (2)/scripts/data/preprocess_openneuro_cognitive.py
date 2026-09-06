"""
SMRITI OpenNeuro Cognitive Dataset Preprocessor & Statistical Inspector
========================================================================
Parses raw BIDS events.tsv files from OpenNeuro ds000164 (Stroop) and ds000102 (Flanker).
Generates standardized trial records and computes programmatic data audit statistics.
"""

import os
import glob
import json
import pandas as pd
import numpy as np
from typing import Dict, List, Tuple, Any

RAW_BASE = "data/raw"
INTERIM_FILE = "data/interim/standardized_cognitive_trials.csv"
PROCESSED_FILE = "data/processed/openneuro_cognitive_trials.csv"
AUDIT_JSON = "data/processed/dataset_audit_stats.json"

def parse_ds000164_stroop(raw_dir: str) -> pd.DataFrame:
    """
    Parses OpenNeuro ds000164 Stroop Task.
    Columns: onset, duration, correct ('Y'/'N'), condition ('neutral','congruent','incongruent'), response_time (sec)
    """
    records = []
    event_files = glob.glob(os.path.join(raw_dir, "sub-*/func/*_events.tsv"))
    
    for fpath in sorted(event_files):
        filename = os.path.basename(fpath)
        sub_id = filename.split("_")[0] # e.g. sub-001
        
        try:
            df = pd.read_csv(fpath, sep="\t")
        except Exception as e:
            print(f"[WARN] Error reading {fpath}: {e}")
            continue

        for idx, row in df.iterrows():
            # Raw fields
            onset = row.get("onset")
            duration = row.get("duration")
            correct_raw = str(row.get("correct", "")).strip().upper()
            condition_raw = str(row.get("condition", "")).strip().lower()
            rt_sec = row.get("response_time")

            # Parse numeric RT
            try:
                rt_val = float(rt_sec) if pd.notnull(rt_sec) else np.nan
            except ValueError:
                rt_val = np.nan

            # Standardize accuracy: 'Y' -> 1.0, 'N' -> 0.0, else nan/0.0
            accuracy = 1.0 if correct_raw == "Y" else (0.0 if correct_raw == "N" else np.nan)
            
            # Standardize condition
            if condition_raw in ["congruent", "incongruent", "neutral"]:
                condition = condition_raw
            else:
                condition = "unknown"

            # RT in milliseconds
            rt_ms = float(rt_val * 1000.0) if pd.notnull(rt_val) and rt_val > 0 else np.nan

            records.append({
                "dataset_accession": "ds000164",
                "participant_id": sub_id,
                "run_id": 1,
                "trial_index": int(idx + 1),
                "task_paradigm": "stroop",
                "stimulus_condition": condition,
                "raw_onset_sec": float(onset) if pd.notnull(onset) else np.nan,
                "raw_duration_sec": float(duration) if pd.notnull(duration) else np.nan,
                "raw_response_time_sec": rt_val,
                "response_time_ms": rt_ms,
                "accuracy": accuracy,
                "is_cognitive_conflict": 1 if condition == "incongruent" else (0 if condition in ["congruent", "neutral"] else np.nan)
            })

    return pd.DataFrame(records)

def parse_ds000102_flanker(raw_dir: str) -> pd.DataFrame:
    """
    Parses OpenNeuro ds000102 Flanker Task.
    Columns: onset, duration, trial_type ('congruent_correct', 'incongruent_correct', ...),
             response_time (sec), correctness ('correct', 'incorrect'), Stimulus ('congruent', 'incongruent')
    """
    records = []
    event_files = glob.glob(os.path.join(raw_dir, "sub-*/func/*_events.tsv"))

    for fpath in sorted(event_files):
        filename = os.path.basename(fpath)
        parts = filename.split("_")
        sub_id = parts[0] # e.g. sub-01
        run_id = 1 if "run-1" in filename else (2 if "run-2" in filename else 1)

        try:
            df = pd.read_csv(fpath, sep="\t")
        except Exception as e:
            print(f"[WARN] Error reading {fpath}: {e}")
            continue

        for idx, row in df.iterrows():
            onset = row.get("onset")
            duration = row.get("duration")
            trial_type = str(row.get("trial_type", "")).strip().lower()
            correctness_raw = str(row.get("correctness", "")).strip().lower()
            stimulus_raw = str(row.get("Stimulus", "")).strip().lower()
            rt_sec = row.get("response_time")

            try:
                rt_val = float(rt_sec) if pd.notnull(rt_sec) else np.nan
            except ValueError:
                rt_val = np.nan

            accuracy = 1.0 if correctness_raw == "correct" else (0.0 if correctness_raw == "incorrect" else np.nan)
            
            if stimulus_raw in ["congruent", "incongruent"]:
                condition = stimulus_raw
            elif "incongruent" in trial_type:
                condition = "incongruent"
            elif "congruent" in trial_type:
                condition = "congruent"
            else:
                condition = "neutral"

            rt_ms = float(rt_val * 1000.0) if pd.notnull(rt_val) and rt_val > 0 else np.nan

            records.append({
                "dataset_accession": "ds000102",
                "participant_id": sub_id,
                "run_id": run_id,
                "trial_index": int(idx + 1),
                "task_paradigm": "flanker",
                "stimulus_condition": condition,
                "raw_onset_sec": float(onset) if pd.notnull(onset) else np.nan,
                "raw_duration_sec": float(duration) if pd.notnull(duration) else np.nan,
                "raw_response_time_sec": rt_val,
                "response_time_ms": rt_ms,
                "accuracy": accuracy,
                "is_cognitive_conflict": 1 if condition == "incongruent" else (0 if condition in ["congruent", "neutral"] else np.nan)
            })

    return pd.DataFrame(records)

def engineer_behavioral_features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Computes lag-1 behavioral autocorrelation features within each subject session.
    Features: prev_response_time_ms, prev_accuracy, cumulative_trial_num,
              response_time_zscore_by_subject
    """
    df = df.sort_values(by=["dataset_accession", "participant_id", "run_id", "trial_index"]).copy()
    
    # Lagged features grouped by subject & run
    df["prev_response_time_ms"] = df.groupby(["dataset_accession", "participant_id", "run_id"])["response_time_ms"].shift(1)
    df["prev_accuracy"] = df.groupby(["dataset_accession", "participant_id", "run_id"])["accuracy"].shift(1)
    df["cumulative_trial_num"] = df.groupby(["dataset_accession", "participant_id", "run_id"]).cumcount() + 1

    # Subject-level baseline reaction time (median across subject)
    subject_median_rt = df.groupby(["dataset_accession", "participant_id"])["response_time_ms"].transform("median")
    subject_std_rt = df.groupby(["dataset_accession", "participant_id"])["response_time_ms"].transform("std")
    
    # Safe z-score computation
    df["rt_zscore_subject"] = (df["response_time_ms"] - subject_median_rt) / subject_std_rt.replace(0, 1.0)
    
    return df

def generate_data_audit(df: pd.DataFrame) -> Dict[str, Any]:
    """
    Generates programmatic data audit statistics across all raw and processed fields.
    """
    stats = {}
    
    for ds_name in ["ds000164", "ds000102", "COMBINED"]:
        sub_df = df if ds_name == "COMBINED" else df[df["dataset_accession"] == ds_name]
        if sub_df.empty:
            continue

        rt_clean = sub_df["response_time_ms"].dropna()
        acc_clean = sub_df["accuracy"].dropna()

        missing_pcts = {col: round(float(sub_df[col].isnull().mean() * 100), 2) for col in sub_df.columns}

        stats[ds_name] = {
            "total_trials": int(len(sub_df)),
            "unique_participants": int(sub_df["participant_id"].nunique()),
            "participant_list": [str(p) for p in sorted(list(sub_df["participant_id"].unique()))],
            "tasks": [str(t) for t in sub_df["task_paradigm"].unique()],
            "conditions": {str(k): int(v) for k, v in sub_df["stimulus_condition"].value_counts().items()},
            "accuracy_distribution": {
                "correct_trials (1.0)": int((acc_clean == 1.0).sum()),
                "incorrect_trials (0.0)": int((acc_clean == 0.0).sum()),
                "overall_accuracy_rate": round(float(acc_clean.mean()), 4) if len(acc_clean) > 0 else 0.0
            },
            "reaction_time_stats_ms": {
                "count_valid_rt": int(len(rt_clean)),
                "min_ms": round(float(rt_clean.min()), 2) if len(rt_clean) > 0 else 0.0,
                "max_ms": round(float(rt_clean.max()), 2) if len(rt_clean) > 0 else 0.0,
                "mean_ms": round(float(rt_clean.mean()), 2) if len(rt_clean) > 0 else 0.0,
                "std_ms": round(float(rt_clean.std()), 2) if len(rt_clean) > 0 else 0.0,
                "median_ms": round(float(rt_clean.median()), 2) if len(rt_clean) > 0 else 0.0,
                "percentile_25_ms": round(float(np.percentile(rt_clean, 25)), 2) if len(rt_clean) > 0 else 0.0,
                "percentile_75_ms": round(float(np.percentile(rt_clean, 75)), 2) if len(rt_clean) > 0 else 0.0,
                "percentile_95_ms": round(float(np.percentile(rt_clean, 95)), 2) if len(rt_clean) > 0 else 0.0
            },
            "rt_outlier_count_gt_3000ms": int((rt_clean > 3000).sum()),
            "rt_outlier_count_lt_150ms": int((rt_clean < 150).sum()),
            "duplicate_rows": int(sub_df.duplicated().sum()),
            "missing_percentages": missing_pcts
        }

    return stats

def run_preprocessing_pipeline() -> Tuple[pd.DataFrame, Dict[str, Any]]:
    print("[SMRITI DATA PREPROCESSOR] Ingesting raw OpenNeuro cognitive datasets...")
    
    raw_164 = os.path.join(RAW_BASE, "openneuro_ds000164_stroop")
    raw_102 = os.path.join(RAW_BASE, "openneuro_ds000102_flanker")

    df_164 = parse_ds000164_stroop(raw_164)
    print(f"  Parsed ds000164 (Stroop): {len(df_164)} trials across {df_164['participant_id'].nunique()} subjects")

    df_102 = parse_ds000102_flanker(raw_102)
    print(f"  Parsed ds000102 (Flanker): {len(df_102)} trials across {df_102['participant_id'].nunique()} subjects")

    combined_raw = pd.concat([df_164, df_102], ignore_index=True)
    os.makedirs(os.path.dirname(INTERIM_FILE), exist_ok=True)
    combined_raw.to_csv(INTERIM_FILE, index=False)
    print(f"  Saved standardized raw trials to {INTERIM_FILE}")

    # Feature Engineering (Lags, cumulative index, subject z-scores)
    processed_df = engineer_behavioral_features(combined_raw)
    os.makedirs(os.path.dirname(PROCESSED_FILE), exist_ok=True)
    processed_df.to_csv(PROCESSED_FILE, index=False)
    print(f"  Saved engineered cognitive trials to {PROCESSED_FILE}")

    # Statistical Audit
    audit_stats = generate_data_audit(processed_df)
    with open(AUDIT_JSON, "w") as f:
        json.dump(audit_stats, f, indent=2)
    print(f"  Saved statistical audit report to {AUDIT_JSON}")

    return processed_df, audit_stats

if __name__ == "__main__":
    df, stats = run_preprocessing_pipeline()
    print("\n--- COMBINED AUDIT SUMMARY ---")
    print(f"Total Trials: {stats['COMBINED']['total_trials']}")
    print(f"Total Unique Participants: {stats['COMBINED']['unique_participants']}")
    print(f"Mean Reaction Time: {stats['COMBINED']['reaction_time_stats_ms']['mean_ms']} ms")
    print(f"Overall Accuracy: {stats['COMBINED']['accuracy_distribution']['overall_accuracy_rate'] * 100:.2f}%")

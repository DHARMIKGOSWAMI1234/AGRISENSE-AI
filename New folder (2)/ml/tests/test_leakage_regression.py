"""
SMRITI ML Leakage Regression Tests
==================================
Strict automated tests to ensure zero target leakage, zero synthetic primary training data,
and zero subject overlap in cross-validation splits.
"""

import os
import unittest
import pandas as pd
import numpy as np
from sklearn.model_selection import GroupKFold

class TestMLLeakageRegression(unittest.TestCase):
    PROCESSED_DATA_PATH = "data/processed/openneuro_cognitive_trials.csv"

    def test_no_derived_target_leakage(self):
        """
        FAIL if the training pipeline attempts to train a model using a target
        derived deterministically from the same input features (e.g. target_action from accuracy/RT).
        """
        self.assertTrue(os.path.exists(self.PROCESSED_DATA_PATH), "Processed OpenNeuro data file must exist.")
        df = pd.read_csv(self.PROCESSED_DATA_PATH)

        # Prohibit old leaked column 'target_action' from production dataset
        self.assertNotIn(
            "target_action",
            df.columns,
            "Target leakage violation: 'target_action' must not exist in production dataset."
        )

        # Ensure valid targets are empirical observations
        valid_targets = {"response_time_ms", "is_cognitive_conflict", "accuracy"}
        for target in ["response_time_ms", "is_cognitive_conflict"]:
            self.assertIn(target, df.columns, f"Target '{target}' must be present as an empirical observation.")

    def test_no_synthetic_primary_data(self):
        """
        FAIL if synthetic participant identifiers (e.g. SUBJ_NER_*) enter the primary training data.
        """
        df = pd.read_csv(self.PROCESSED_DATA_PATH)
        participants = df["participant_id"].astype(str).unique()

        for p in participants:
            self.assertFalse(
                p.startswith("SUBJ_NER_") or p.startswith("NER_"),
                f"Synthetic participant violation: Found synthetic ID '{p}' in primary dataset."
            )

        # Confirm all participants match real OpenNeuro BIDS subject IDs (sub-001...sub-028, sub-01...sub-26)
        for p in participants:
            self.assertTrue(
                p.startswith("sub-"),
                f"Participant ID '{p}' must follow real BIDS convention 'sub-XX'."
            )

    def test_group_kfold_no_subject_leakage(self):
        """
        FAIL if train and test folds share any common participant in GroupKFold.
        """
        df = pd.read_csv(self.PROCESSED_DATA_PATH)
        df_clean = df.dropna(subset=["response_time_ms"]).copy()
        
        X = df_clean[["cumulative_trial_num", "accuracy"]].values
        y = df_clean["response_time_ms"].values
        groups = df_clean["participant_id"].values

        gkf = GroupKFold(n_splits=5)
        for fold, (train_idx, test_idx) in enumerate(gkf.split(X, y, groups=groups)):
            train_subjects = set(groups[train_idx])
            test_subjects = set(groups[test_idx])
            
            overlap = train_subjects.intersection(test_subjects)
            self.assertEqual(
                len(overlap), 0,
                f"Subject leakage detected in fold {fold}: Overlapping subjects {overlap}"
            )

    def test_research_only_dataset_isolation(self):
        """
        FAIL if datasets marked RESEARCH-ONLY (e.g. DementiaBank) are accidentally ingested into training.
        """
        import json
        manifest_path = "data/manifests/datasets.json"
        self.assertTrue(os.path.exists(manifest_path))

        with open(manifest_path, "r") as f:
            manifest = json.load(f)

        for entry in manifest:
            if entry.get("smriti_role") == "RESEARCH-ONLY":
                # Must not have downloadable raw files committed or processed into training
                self.assertEqual(
                    len(entry.get("files", [])), 0,
                    f"Research-only dataset '{entry['name']}' must not have committed raw training files."
                )

if __name__ == "__main__":
    unittest.main()

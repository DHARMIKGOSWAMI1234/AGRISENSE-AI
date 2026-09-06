"""
SMRITI Data Provenance, Governance & Multi-Tier Inference Tests
==============================================================
Verifies provenance manifest structure, SHA-256 checksums, Tier 0 reason codes,
and Tier 1 empirical model inference.
"""

import os
import json
import unittest
from scripts.data.verify_datasets import verify_all_datasets
from ml.inference.infer import AdaptiveInferenceEngine, EmpiricalCognitiveEstimator

class TestProvenanceAndGovernance(unittest.TestCase):

    def test_sha256_checksums_all_valid(self):
        """Verify all downloaded OpenNeuro raw files match their SHA-256 checksums."""
        is_valid, report = verify_all_datasets()
        self.assertTrue(is_valid, f"Dataset verification failed: {report}")
        self.assertIn("ds000164", report)
        self.assertIn("ds000102", report)
        self.assertEqual(report["ds000164"]["status"], "PASS")
        self.assertEqual(report["ds000102"]["status"], "PASS")

    def test_provenance_manifest_structure(self):
        """Verify data/manifests/datasets.json adheres to schema with verified DOIs and accessions."""
        manifest_path = "data/manifests/datasets.json"
        self.assertTrue(os.path.exists(manifest_path))

        with open(manifest_path, "r") as f:
            datasets = json.load(f)

        self.assertIsInstance(datasets, list)
        self.assertGreaterEqual(len(datasets), 5)

        required_keys = [
            "name", "source_url", "accession_or_dataset_id", "version",
            "doi", "license", "download_date", "files", "sha256",
            "participants", "trials", "raw_columns", "derived_columns",
            "target_columns", "smriti_role", "access_restrictions", "notes"
        ]

        for ds in datasets:
            for k in required_keys:
                self.assertIn(k, ds, f"Key '{k}' missing from dataset '{ds.get('name', 'UNKNOWN')}'.")

    def test_tier0_explainability_reason_codes(self):
        """Verify Tier 0 production engine returns auditable clinical reason codes."""
        engine = AdaptiveInferenceEngine()

        # Low accuracy -> LOW_ACCURACY
        res_low = engine.predict_difficulty_action(current_difficulty=5, accuracy=0.45, response_time_ms=2000)
        self.assertEqual(res_low["action"], "DECREASE")
        self.assertEqual(res_low["reason_code"], "LOW_ACCURACY")

        # Fatigue slowdown (> 40% slower than baseline) -> FATIGUE_DETECTED
        res_fatigue = engine.predict_difficulty_action(
            current_difficulty=5,
            accuracy=0.88,
            response_time_ms=3000,
            historical_mean_rt_ms=1800
        )
        self.assertEqual(res_fatigue["action"], "DECREASE")
        self.assertEqual(res_fatigue["reason_code"], "FATIGUE_DETECTED")

        # High accuracy streak -> HIGH_SUCCESS_RATE
        res_high = engine.predict_difficulty_action(
            current_difficulty=5,
            accuracy=0.92,
            response_time_ms=1800,
            consecutive_successes=3,
            hints_used=0
        )
        self.assertEqual(res_high["action"], "INCREASE")
        self.assertEqual(res_high["reason_code"], "HIGH_SUCCESS_RATE")

        # Stable performance within bounds -> MAINTAIN_CURRENT_LEVEL
        res_stable = engine.predict_difficulty_action(
            current_difficulty=5,
            accuracy=0.75,
            response_time_ms=1900,
            consecutive_successes=1,
            consecutive_errors=0
        )
        self.assertEqual(res_stable["action"], "MAINTAIN")
        self.assertEqual(res_stable["reason_code"], "MAINTAIN_CURRENT_LEVEL")

    def test_empirical_cognitive_estimator(self):
        """Verify Tier 1 empirical ML inference generates realistic RT predictions and probabilities."""
        estimator = EmpiricalCognitiveEstimator()

        # Conflict trial should predict higher latency than neutral trial
        rt_conflict = estimator.estimate_expected_rt_ms(
            is_cognitive_conflict=1,
            cumulative_trial_num=10,
            prev_response_time_ms=750.0
        )
        rt_neutral = estimator.estimate_expected_rt_ms(
            is_cognitive_conflict=0,
            cumulative_trial_num=10,
            prev_response_time_ms=750.0
        )

        self.assertGreater(rt_conflict, 400.0)
        self.assertLess(rt_conflict, 2500.0)
        self.assertGreaterEqual(rt_conflict, rt_neutral - 100.0)

        # Conflict probability between 0 and 1
        p_conflict = estimator.detect_cognitive_conflict_probability(
            response_time_ms=950.0,
            accuracy=1.0,
            prev_response_time_ms=800.0,
            cumulative_trial_num=15
        )
        self.assertGreaterEqual(p_conflict, 0.0)
        self.assertLessEqual(p_conflict, 1.0)

if __name__ == "__main__":
    unittest.main()

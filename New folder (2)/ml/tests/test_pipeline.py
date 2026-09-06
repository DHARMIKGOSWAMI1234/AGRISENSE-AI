"""
SMRITI ML Pipeline Test Suite
=============================
Tests inference engine fallbacks, reason code validity, and model serialization.
"""

import unittest
import os
from ml.inference.infer import AdaptiveInferenceEngine, EmpiricalCognitiveEstimator

class TestMLPipeline(unittest.TestCase):

    def test_tier0_adaptive_rules(self):
        engine = AdaptiveInferenceEngine()
        
        # Test reduction on low accuracy
        res_low = engine.predict_difficulty_action(
            current_difficulty=3,
            accuracy=0.4,
            error_count=4,
            hints_used=2,
            response_time_ms=4000,
            consecutive_errors=2
        )
        self.assertEqual(res_low["action"], "DECREASE")
        self.assertEqual(res_low["next_difficulty"], 2)
        self.assertIn(res_low["reason_code"], ["LOW_ACCURACY", "REPEATED_ERRORS", "FATIGUE_OR_ABANDONMENT"])

        # Test advance on high accuracy
        res_high = engine.predict_difficulty_action(
            current_difficulty=3,
            accuracy=0.95,
            error_count=0,
            hints_used=0,
            response_time_ms=1500,
            consecutive_successes=2
        )
        self.assertEqual(res_high["action"], "INCREASE")
        self.assertEqual(res_high["next_difficulty"], 4)
        self.assertEqual(res_high["reason_code"], "HIGH_SUCCESS_RATE")

    def test_tier1_model_loading(self):
        estimator = EmpiricalCognitiveEstimator()
        self.assertIsNotNone(estimator.rt_pipeline)
        self.assertIsNotNone(estimator.conflict_pipeline)

if __name__ == "__main__":
    unittest.main()

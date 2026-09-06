"""
SMRITI Multi-Tier Inference Engine
==================================
Tier 0 (Production Decision): Explainable Deterministic Rule Engine
Tier 1 (Empirical Calibration): OpenNeuro Cognitive Latency & Conflict Inference
"""

import os
import joblib
import pandas as pd
import numpy as np
from typing import Dict, Any, Optional

from backend.app.services.ai.adaptive import AdaptiveEngine, AdaptiveEngineConfig

class AdaptiveInferenceEngine:
    """
    Tier 0 Production Adaptive Engine with transparent clinical reason codes.
    """
    def __init__(self, config: Optional[AdaptiveEngineConfig] = None):
        self.engine = AdaptiveEngine(config=config)
        self.version = "v2.0.0-tier0-rules"
        self.engine_type = "RULE_BASED_ADAPTATION"

    def predict_difficulty_action(
        self,
        current_difficulty: int,
        accuracy: float,
        response_time_ms: int,
        error_count: int = 0,
        hints_used: int = 0,
        consecutive_successes: int = 0,
        consecutive_errors: int = 0,
        completion_rate: float = 1.0,
        historical_mean_rt_ms: int = 0,
        game_type: str = "memory_match"
    ) -> Dict[str, Any]:
        """
        Executes explainable rule-based adaptation with auditable clinical reason codes.
        """
        next_diff, reason_code = self.engine.evaluate_performance(
            game_type=game_type,
            current_difficulty=current_difficulty,
            accuracy=accuracy,
            error_count=error_count,
            response_time_ms=response_time_ms,
            hints_used=hints_used,
            consecutive_successes=consecutive_successes,
            consecutive_failures=consecutive_errors,
            completion_rate=completion_rate,
            historical_mean_rt_ms=historical_mean_rt_ms
        )

        action = "MAINTAIN"
        if next_diff > current_difficulty:
            action = "INCREASE"
        elif next_diff < current_difficulty:
            action = "DECREASE"

        return {
            "action": action,
            "next_difficulty": next_diff,
            "reason_code": reason_code,
            "engine_type": self.engine_type,
            "version": self.version
        }


class EmpiricalCognitiveEstimator:
    """
    Tier 1 Empirical Cognitive Research & Calibration Models Ingested from OpenNeuro Corpora.
    - Task A: Empirical healthy-adult response latency estimator (Informs initial engineering ranges).
    - Task B: Behavioral conflict classification benchmark (Retained for pipeline evaluation; NOT patient-facing).

    DISCLAIMER: These models provide empirical healthy-adult behavioral reference distributions.
    They DO NOT establish clinical dementia norms, DO NOT predict game difficulty, and DO NOT make clinical decisions.
    """
    def __init__(
        self,
        rt_model_path: str = "ml/models/registry/cognitive_reaction_time_regressor.joblib",
        conflict_model_path: str = "ml/models/registry/cognitive_conflict_classifier.joblib"
    ):
        self.rt_pipeline = None
        self.conflict_pipeline = None

        if os.path.exists(rt_model_path):
            try:
                art = joblib.load(rt_model_path)
                self.rt_pipeline = art["pipeline"]
            except Exception as e:
                print(f"[EmpiricalCognitiveEstimator] Warning: RT model load failed ({e})")

        if os.path.exists(conflict_model_path):
            try:
                art = joblib.load(conflict_model_path)
                self.conflict_pipeline = art["pipeline"]
            except Exception as e:
                print(f"[EmpiricalCognitiveEstimator] Warning: Conflict model load failed ({e})")

    def estimate_expected_rt_ms(
        self,
        is_cognitive_conflict: int,
        cumulative_trial_num: int,
        prev_response_time_ms: float,
        prev_accuracy: float = 1.0,
        task_is_stroop: float = 1.0
    ) -> float:
        """Predicts expected reaction latency in ms based on cognitive load."""
        if not self.rt_pipeline:
            # Empirical fallback mean from OpenNeuro corpus (745ms + 80ms conflict)
            return 745.0 + (80.0 if is_cognitive_conflict else 0.0)

        X = np.array([[is_cognitive_conflict, cumulative_trial_num, prev_response_time_ms, prev_accuracy, task_is_stroop]])
        return float(self.rt_pipeline.predict(X)[0])

    def detect_cognitive_conflict_probability(
        self,
        response_time_ms: float,
        accuracy: float,
        prev_response_time_ms: float,
        cumulative_trial_num: int,
        task_is_stroop: float = 1.0
    ) -> float:
        """Estimates probability that current trial posed cognitive conflict."""
        if not self.conflict_pipeline:
            return 0.5

        X = np.array([[response_time_ms, accuracy, prev_response_time_ms, cumulative_trial_num, task_is_stroop]])
        if hasattr(self.conflict_pipeline, "predict_proba"):
            return float(self.conflict_pipeline.predict_proba(X)[0][1])
        return float(self.conflict_pipeline.predict(X)[0])

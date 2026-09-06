"""
SMRITI Production Adaptive Difficulty Engine (Tier 0)
=====================================================
Implements explainable, deterministic rule-based cognitive difficulty calibration
with configurable clinical thresholds and structured audit reason codes.

This engine is explicitly classified as a RULE-BASED ADAPTIVE SYSTEM, not a black-box ML model.
"""

from typing import Dict, Any, Tuple
from dataclasses import dataclass

@dataclass
class AdaptiveEngineConfig:
    min_difficulty: int = 1
    max_difficulty: int = 10
    high_accuracy_threshold: float = 0.85
    low_accuracy_threshold: float = 0.60
    success_streak_required: int = 2
    failure_streak_required: int = 2
    min_completion_rate: float = 0.50
    slow_response_ms: int = 8000
    fatigue_slowdown_pct: float = 0.40

class AdaptiveEngine:
    """
    Tier 0 Explainable Deterministic Adaptive Difficulty Engine.
    Produces auditable next-difficulty steps with transparent reason codes.
    """

    def __init__(self, config: AdaptiveEngineConfig = None):
        self.config = config or AdaptiveEngineConfig()

    @staticmethod
    def evaluate_performance(
        game_type: str,
        current_difficulty: int,
        accuracy: float,
        error_count: int,
        response_time_ms: int,
        hints_used: int,
        consecutive_successes: int = 0,
        consecutive_failures: int = 0,
        completion_rate: float = 1.0,
        historical_mean_rt_ms: int = 0,
        config: AdaptiveEngineConfig = None
    ) -> Tuple[int, str]:
        """
        Calculates next difficulty level and returns an auditable reason code.
        Returns: (next_difficulty_level, reason_code)
        """
        cfg = config or AdaptiveEngineConfig()

        # 1. Incompletion / Abandonment
        if completion_rate < cfg.min_completion_rate:
            next_diff = max(cfg.min_difficulty, current_difficulty - 1)
            return next_diff, "FATIGUE_OR_ABANDONMENT"

        # 2. Significant cognitive fatigue (RT slowed by > 40% over baseline)
        if historical_mean_rt_ms > 0 and response_time_ms > (historical_mean_rt_ms * (1.0 + cfg.fatigue_slowdown_pct)):
            next_diff = max(cfg.min_difficulty, current_difficulty - 1)
            return next_diff, "FATIGUE_DETECTED"

        # 3. Low accuracy threshold breach
        if accuracy < cfg.low_accuracy_threshold:
            next_diff = max(cfg.min_difficulty, current_difficulty - 1)
            return next_diff, "LOW_ACCURACY"

        # 4. Repeated consecutive failures
        if consecutive_failures >= cfg.failure_streak_required:
            next_diff = max(cfg.min_difficulty, current_difficulty - 1)
            return next_diff, "REPEATED_ERRORS"

        # 5. Excessive response latency
        if response_time_ms > cfg.slow_response_ms:
            next_diff = max(cfg.min_difficulty, current_difficulty - 1)
            return next_diff, "SLOW_RESPONSE"

        # 6. High success streak -> Advance difficulty
        if accuracy >= cfg.high_accuracy_threshold and consecutive_successes >= cfg.success_streak_required and hints_used == 0:
            next_diff = min(cfg.max_difficulty, current_difficulty + 1)
            return next_diff, "HIGH_SUCCESS_RATE"

        # 7. Stable baseline performance -> Maintain current level
        return current_difficulty, "MAINTAIN_CURRENT_LEVEL"

    @classmethod
    def evaluate(cls, **kwargs) -> Tuple[int, str]:
        """Convenience class method using default configuration."""
        engine = cls()
        return engine.evaluate_performance(**kwargs)

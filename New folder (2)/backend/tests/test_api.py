import unittest
import sys
import os

# Add backend directory to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.services.ai.adaptive import AdaptiveEngine
from app.services.ai.trends import TrendsService
from app.models.game_session import GameSession
from datetime import datetime, timezone

class TestBackendDomainAndAI(unittest.TestCase):
    def test_tier_0_adaptive_rules(self):
        # High accuracy rule -> Step up
        next_diff, reason = AdaptiveEngine.evaluate_performance(
            game_type="memory_match",
            current_difficulty=1,
            accuracy=0.9,
            error_count=0,
            response_time_ms=2000,
            hints_used=0,
            consecutive_successes=2
        )
        self.assertEqual(next_diff, 2)
        self.assertEqual(reason, "HIGH_SUCCESS_RATE")

        # Low accuracy rule -> Step down
        next_diff, reason = AdaptiveEngine.evaluate_performance(
            game_type="memory_match",
            current_difficulty=2,
            accuracy=0.4,
            error_count=3,
            response_time_ms=4500,
            hints_used=2,
            consecutive_successes=0
        )
        self.assertEqual(next_diff, 1)
        self.assertEqual(reason, "LOW_ACCURACY")

    def test_non_diagnostic_trends_calculation(self):
        sample_sessions = [
            GameSession(
                event_id="evt_01",
                patient_id="pat_01",
                game_type="memory_match",
                difficulty_level=2,
                accuracy=0.85,
                score=8.5,
                error_count=1,
                hints_used=0,
                duration_ms=30000,
                occurred_at=datetime.now(timezone.utc)
            ),
            GameSession(
                event_id="evt_02",
                patient_id="pat_01",
                game_type="routine_recall",
                difficulty_level=1,
                accuracy=0.95,
                score=9.5,
                error_count=0,
                hints_used=0,
                duration_ms=25000,
                occurred_at=datetime.now(timezone.utc)
            )
        ]

        summary = TrendsService.calculate_longitudinal_summary(sample_sessions, window_days=7)
        self.assertEqual(summary["total_sessions"], 2)
        self.assertEqual(summary["average_accuracy"], 0.9)
        self.assertGreater(summary["cognitive_engagement_index"], 50)
        self.assertIn("Not a medical dementia assessment", summary["non_diagnostic_note"])

if __name__ == "__main__":
    unittest.main()

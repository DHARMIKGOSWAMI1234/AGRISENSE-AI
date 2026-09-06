from typing import List, Dict, Any
from datetime import datetime, timezone, timedelta
from app.models.game_session import GameSession

class TrendsService:
    """
    Computes non-diagnostic longitudinal engagement trends.
    Strictly adheres to WHO guidelines: outputs activity metrics, not dementia diagnosis.
    """

    @staticmethod
    def calculate_longitudinal_summary(sessions: List[GameSession], window_days: int = 7) -> Dict[str, Any]:
        if not sessions:
            return {
                "window_days": window_days,
                "total_sessions": 0,
                "average_accuracy": 0.0,
                "average_duration_sec": 0.0,
                "preferred_game": None,
                "cognitive_engagement_index": 0.0,
                "trend_status": "NO_DATA",
                "non_diagnostic_note": "Activity participation records are updated as games are synchronized."
            }

        total = len(sessions)
        avg_acc = sum(s.accuracy for s in sessions) / total
        avg_dur = sum(s.duration_ms for s in sessions) / total / 1000.0

        # Frequency breakdown
        game_counts: Dict[str, int] = {}
        for s in sessions:
            game_counts[s.game_type] = game_counts.get(s.game_type, 0) + 1
        
        pref_game = max(game_counts, key=game_counts.get) if game_counts else None

        # Cognitive Engagement Index (Normalized 0-100 score based purely on participation & consistency)
        consistency_factor = min(1.0, total / max(1, window_days))
        cei = round((avg_acc * 0.5 + consistency_factor * 0.5) * 100, 1)

        return {
            "window_days": window_days,
            "total_sessions": total,
            "average_accuracy": round(avg_acc, 2),
            "average_duration_sec": round(avg_dur, 1),
            "preferred_game": pref_game,
            "cognitive_engagement_index": cei,
            "trend_status": "CONSISTENT" if cei >= 65 else "EMERGING",
            "non_diagnostic_note": "Shows cognitive activity engagement. Not a medical dementia assessment."
        }

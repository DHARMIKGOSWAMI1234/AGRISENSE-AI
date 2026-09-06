from typing import Dict, Any, List
from app.services.ai.adaptive import AdaptiveEngine

class RecommendationService:
    """
    Coordinates adaptive difficulty recommendations across games.
    """

    AVAILABLE_GAMES = [
        "memory_match",
        "pattern",
        "routine_recall",
        "object_memory",
        "reminiscence"
    ]

    @staticmethod
    def recommend_next_activity(patient_preferences: Dict[str, Any], recent_sessions: List[Any]) -> Dict[str, Any]:
        if not recent_sessions:
            return {
                "recommended_game": "memory_match",
                "recommended_difficulty": 1,
                "reason_code": "INITIAL_ONBOARDING",
                "message": "Welcome! Let's start with an introductory memory pairing activity."
            }

        last_session = recent_sessions[0]
        next_diff, reason = AdaptiveEngine.evaluate_performance(
            game_type=last_session.game_type,
            current_difficulty=last_session.difficulty_level,
            accuracy=last_session.accuracy,
            error_count=last_session.error_count,
            response_time_ms=last_session.duration_ms,
            hints_used=last_session.hints_used
        )

        return {
            "recommended_game": last_session.game_type,
            "recommended_difficulty": next_diff,
            "reason_code": reason,
            "message": f"Difficulty adjusted to Level {next_diff} ({reason})."
        }

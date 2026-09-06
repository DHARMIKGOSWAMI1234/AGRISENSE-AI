import 'game_type.dart';

class CognitiveGameResult {
  final String sessionId;
  final String patientId;
  final CognitiveGameType gameType;
  final int difficultyLevel;
  final int totalTargets;
  final int correctCount;
  final int missedCount;
  final int incorrectCount;
  final double accuracy; // [0.0, 1.0]
  final double score; // [0.0, 100.0]
  final int responseTimeMs;
  final int studyDurationMs;
  final int hintsUsed;
  final bool isCompleted;
  final DateTime occurredAt;
  final int nextDifficulty;
  final String reasonCode;
  final String feedbackMessage;

  const CognitiveGameResult({
    required this.sessionId,
    required this.patientId,
    required this.gameType,
    required this.difficultyLevel,
    required this.totalTargets,
    required this.correctCount,
    required this.missedCount,
    required this.incorrectCount,
    required this.accuracy,
    required this.score,
    required this.responseTimeMs,
    required this.studyDurationMs,
    required this.hintsUsed,
    required this.isCompleted,
    required this.occurredAt,
    required this.nextDifficulty,
    required this.reasonCode,
    required this.feedbackMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'patient_id': patientId,
      'game_type': gameType.id,
      'difficulty_level': difficultyLevel,
      'total_targets': totalTargets,
      'correct_count': correctCount,
      'missed_count': missedCount,
      'incorrect_count': incorrectCount,
      'accuracy': accuracy,
      'score': score,
      'response_time_ms': responseTimeMs,
      'study_duration_ms': studyDurationMs,
      'hints_used': hintsUsed,
      'is_completed': isCompleted,
      'occurred_at': occurredAt.toIso8601String(),
      'next_difficulty': nextDifficulty,
      'reason_code': reasonCode,
      'feedback_message': feedbackMessage,
    };
  }
}

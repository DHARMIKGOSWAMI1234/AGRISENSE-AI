class GameSessionModel {
  final String localId;
  final String eventId;
  final String patientId;
  final String gameType;
  final int difficultyLevel;
  final double accuracy;
  final double score;
  final int errorCount;
  final int hintsUsed;
  final int durationMs;
  final String? recommendationReason;
  final DateTime occurredAt;
  final String syncStatus; // 'PENDING', 'SYNCED', 'FAILED'

  GameSessionModel({
    required this.localId,
    required this.eventId,
    required this.patientId,
    required this.gameType,
    required this.difficultyLevel,
    required this.accuracy,
    required this.score,
    required this.errorCount,
    required this.hintsUsed,
    required this.durationMs,
    this.recommendationReason,
    required this.occurredAt,
    this.syncStatus = 'PENDING',
  });

  Map<String, dynamic> toMap() {
    return {
      'local_id': localId,
      'event_id': eventId,
      'patient_id': patientId,
      'game_type': gameType,
      'difficulty_level': difficultyLevel,
      'accuracy': accuracy,
      'score': score,
      'error_count': errorCount,
      'hints_used': hintsUsed,
      'duration_ms': durationMs,
      'recommendation_reason': recommendationReason,
      'occurred_at': occurredAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  factory GameSessionModel.fromMap(Map<String, dynamic> map) {
    return GameSessionModel(
      localId: map['local_id'],
      eventId: map['event_id'],
      patientId: map['patient_id'],
      gameType: map['game_type'],
      difficultyLevel: map['difficulty_level'],
      accuracy: (map['accuracy'] as num).toDouble(),
      score: (map['score'] as num).toDouble(),
      errorCount: map['error_count'],
      hintsUsed: map['hints_used'],
      durationMs: map['duration_ms'],
      recommendationReason: map['recommendation_reason'],
      occurredAt: DateTime.parse(map['occurred_at']),
      syncStatus: map['sync_status'] ?? 'PENDING',
    );
  }
}

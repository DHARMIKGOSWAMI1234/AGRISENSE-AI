import 'package:smriti_mobile/domain/adaptive/adaptive_engine.dart';
import 'package:smriti_mobile/features/cognitive_games/domain/models/game_result.dart';
import 'package:smriti_mobile/features/cognitive_games/engine/scoring_engine.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/domain/spatial_pattern_config.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/domain/spatial_pattern_state.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/engine/spatial_pattern_generator.dart';

class SpatialPatternRoundResult {
  final int roundIndex;
  final Set<GridCoordinate> targetPattern;
  final Set<GridCoordinate> userSelection;
  final int correctCount;
  final int missedCount;
  final int incorrectCount;
  final double score;
  final int responseTimeMs;
  final int studyTimeMs;

  const SpatialPatternRoundResult({
    required this.roundIndex,
    required this.targetPattern,
    required this.userSelection,
    required this.correctCount,
    required this.missedCount,
    required this.incorrectCount,
    required this.score,
    required this.responseTimeMs,
    required this.studyTimeMs,
  });
}

class SpatialPatternEngine {
  final SpatialPatternDifficultyConfig config;
  final String patientId;
  final String sessionId;

  SpatialPatternPhase _phase = SpatialPatternPhase.intro;
  int _currentRound = 1;
  Set<GridCoordinate> _targetPattern = {};
  Set<GridCoordinate> _userSelection = {};
  int _hintsUsed = 0;

  final Stopwatch _studyStopwatch = Stopwatch();
  final Stopwatch _responseStopwatch = Stopwatch();
  final List<SpatialPatternRoundResult> _roundHistory = [];

  SpatialPatternEngine({
    required this.config,
    required this.patientId,
    required this.sessionId,
  });

  // Getters
  SpatialPatternPhase get phase => _phase;
  int get currentRound => _currentRound;
  int get totalRounds => config.roundCount;
  int get gridSize => config.gridSize;
  int get targetCount => config.patternCellCount;
  Set<GridCoordinate> get targetPattern => Set.unmodifiable(_targetPattern);
  Set<GridCoordinate> get userSelection => Set.unmodifiable(_userSelection);
  int get hintsUsed => _hintsUsed;
  List<SpatialPatternRoundResult> get roundHistory => List.unmodifiable(_roundHistory);

  /// Starts the round in STUDY phase with a generated pattern
  void startRound({int? seed}) {
    _phase = SpatialPatternPhase.study;
    _userSelection = {};
    _targetPattern = SpatialPatternGenerator.generatePattern(
      gridSize: config.gridSize,
      cellCount: config.patternCellCount,
      seed: seed,
    );

    _studyStopwatch.reset();
    _studyStopwatch.start();
  }

  /// Transitions from STUDY to RECALL phase
  void transitionToRecall() {
    _studyStopwatch.stop();
    _phase = SpatialPatternPhase.recall;
    _responseStopwatch.reset();
    _responseStopwatch.start();
  }

  /// Handles user tapping a grid cell in RECALL phase
  bool toggleCell(GridCoordinate coord) {
    if (_phase != SpatialPatternPhase.recall) return false;

    if (_userSelection.contains(coord)) {
      _userSelection.remove(coord);
    } else {
      _userSelection.add(coord);
    }
    return true;
  }

  /// Evaluates submitted selections in FEEDBACK phase
  CognitiveScoringResult submitAnswer() {
    _responseStopwatch.stop();
    _phase = SpatialPatternPhase.feedback;

    final int correctCount = _userSelection.intersection(_targetPattern).length;
    final int incorrectCount = _userSelection.difference(_targetPattern).length;

    final scoringResult = CognitiveScoringEngine.calculateScore(
      totalTargets: _targetPattern.length,
      correctCount: correctCount,
      incorrectCount: incorrectCount,
    );

    _roundHistory.add(SpatialPatternRoundResult(
      roundIndex: _currentRound,
      targetPattern: Set.from(_targetPattern),
      userSelection: Set.from(_userSelection),
      correctCount: correctCount,
      missedCount: scoringResult.missedCount,
      incorrectCount: incorrectCount,
      score: scoringResult.score,
      responseTimeMs: _responseStopwatch.elapsedMilliseconds,
      studyTimeMs: _studyStopwatch.elapsedMilliseconds,
    ));

    return scoringResult;
  }

  /// Increments hint counter
  void recordHintUsed() {
    _hintsUsed++;
  }

  /// Advances to next round or marks session complete
  bool advanceOrComplete() {
    if (_currentRound < config.roundCount) {
      _currentRound++;
      _phase = SpatialPatternPhase.roundComplete;
      return false; // Not finished
    } else {
      _phase = SpatialPatternPhase.sessionComplete;
      return true; // Finished
    }
  }

  /// Compiles final session result with Tier 0 adaptive difficulty recommendation
  CognitiveGameResult buildFinalResult() {
    int totalCorrect = 0;
    int totalMissed = 0;
    int totalIncorrect = 0;
    int totalTargets = 0;
    int totalResponseTimeMs = 0;
    int totalStudyDurationMs = 0;

    for (final r in _roundHistory) {
      totalCorrect += r.correctCount;
      totalMissed += r.missedCount;
      totalIncorrect += r.incorrectCount;
      totalTargets += r.targetPattern.length;
      totalResponseTimeMs += r.responseTimeMs;
      totalStudyDurationMs += r.studyTimeMs;
    }

    final double overallAccuracy = (totalTargets > 0)
        ? (totalCorrect / totalTargets).clamp(0.0, 1.0)
        : 1.0;

    final double averageScore = _roundHistory.isNotEmpty
        ? _roundHistory.map((r) => r.score).reduce((a, b) => a + b) / _roundHistory.length
        : 0.0;

    // Evaluate Tier 0 Adaptive Engine
    final decision = MobileAdaptiveEngine.evaluate(
      currentDifficulty: config.difficultyLevel,
      accuracy: overallAccuracy,
      errorCount: totalIncorrect + totalMissed,
      hintsUsed: _hintsUsed,
      responseTimeMs: totalResponseTimeMs,
      consecutiveSuccesses: (overallAccuracy >= 0.85) ? 1 : 0,
      consecutiveFailures: (overallAccuracy < 0.60) ? 1 : 0,
    );

    return CognitiveGameResult(
      sessionId: sessionId,
      patientId: patientId,
      gameType: CognitiveGameType.spatialPattern,
      difficultyLevel: config.difficultyLevel,
      totalTargets: totalTargets,
      correctCount: totalCorrect,
      missedCount: totalMissed,
      incorrectCount: totalIncorrect,
      accuracy: overallAccuracy,
      score: averageScore,
      responseTimeMs: totalResponseTimeMs,
      studyDurationMs: totalStudyDurationMs,
      hintsUsed: _hintsUsed,
      isCompleted: true,
      occurredAt: DateTime.now(),
      nextDifficulty: decision.nextDifficulty,
      reasonCode: decision.reasonCode,
      feedbackMessage: decision.userMessage,
    );
  }
}

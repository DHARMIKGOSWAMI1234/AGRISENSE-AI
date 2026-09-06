import 'package:flutter_test/flutter_test.dart';
import 'package:smriti_mobile/data/local/database/app_database.dart';
import 'package:smriti_mobile/data/models/game_session_model.dart';
import 'package:smriti_mobile/features/cognitive_games/engine/scoring_engine.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/domain/spatial_pattern_config.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/domain/spatial_pattern_state.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/engine/spatial_pattern_engine.dart';

void main() {
  group('CognitiveScoringEngine Tests', () {
    test('Perfect recall produces 100 score and high accuracy', () {
      final result = CognitiveScoringEngine.calculateScore(
        totalTargets: 4,
        correctCount: 4,
        incorrectCount: 0,
      );

      expect(result.score, 100.0);
      expect(result.accuracy, 1.0);
      expect(result.recall, 1.0);
      expect(result.precision, 1.0);
      expect(result.missedCount, 0);
      expect(result.incorrectCount, 0);
      expect(result.feedbackMessage, contains('Splendid!'));
    });

    test('Partial recall reduces score proportionately', () {
      final result = CognitiveScoringEngine.calculateScore(
        totalTargets: 4,
        correctCount: 2,
        incorrectCount: 0,
      );

      expect(result.score, 50.0);
      expect(result.accuracy, 0.5);
      expect(result.recall, 0.5);
      expect(result.precision, 1.0);
      expect(result.missedCount, 2);
      expect(result.feedbackMessage, contains('Good effort!'));
    });

    test('False selections (extra wrong taps) reduce accuracy and score', () {
      final result = CognitiveScoringEngine.calculateScore(
        totalTargets: 4,
        correctCount: 2,
        incorrectCount: 2,
      );

      // Raw accuracy = (2 - 0.5 * 2) / 4 = 1/4 = 0.25 -> score = 25
      expect(result.accuracy, 0.25);
      expect(result.score, 25.0);
      expect(result.incorrectCount, 2);
      expect(result.missedCount, 2);
      expect(result.precision, 0.5); // 2 correct out of 4 total selected
    });

    test('Zero correct selections produces 0 score and encouraging fallback', () {
      final result = CognitiveScoringEngine.calculateScore(
        totalTargets: 3,
        correctCount: 0,
        incorrectCount: 1,
      );

      expect(result.score, 0.0);
      expect(result.accuracy, 0.0);
      expect(result.feedbackMessage, contains('That’s okay!'));
    });
  });

  group('SpatialPatternEngine State Transitions & Gameplay', () {
    test('Round life-cycle executes from intro to study to recall to feedback to complete', () {
      final config = SpatialPatternDifficultyConfig.forLevel(1); // 3 rounds
      final engine = SpatialPatternEngine(
        config: config,
        patientId: 'patient_test_01',
        sessionId: 'sess_test_01',
      );

      expect(engine.phase, SpatialPatternPhase.intro);
      expect(engine.currentRound, 1);

      // 1. Start Round 1
      engine.startRound(seed: 100);
      expect(engine.phase, SpatialPatternPhase.study);
      expect(engine.targetPattern.length, config.patternCellCount);
      expect(engine.userSelection.isEmpty, true);

      // 2. Transition to Recall
      engine.transitionToRecall();
      expect(engine.phase, SpatialPatternPhase.recall);

      // 3. User taps cells
      final target = engine.targetPattern.first;
      engine.toggleCell(target);
      expect(engine.userSelection.contains(target), true);

      // Toggle off and on
      engine.toggleCell(target);
      expect(engine.userSelection.contains(target), false);
      engine.toggleCell(target);
      expect(engine.userSelection.contains(target), true);

      // 4. Submit Answer
      final score = engine.submitAnswer();
      expect(engine.phase, SpatialPatternPhase.feedback);
      expect(score.correctCount, 1);

      // 5. Advance to Round 2
      final isDone1 = engine.advanceOrComplete();
      expect(isDone1, false);
      expect(engine.currentRound, 2);

      // Play Round 2
      engine.startRound(seed: 200);
      engine.transitionToRecall();
      for (final cell in engine.targetPattern) {
        engine.toggleCell(cell);
      }
      engine.submitAnswer();
      final isDone2 = engine.advanceOrComplete();
      expect(isDone2, false);
      expect(engine.currentRound, 3);

      // Play Round 3
      engine.startRound(seed: 300);
      engine.transitionToRecall();
      for (final cell in engine.targetPattern) {
        engine.toggleCell(cell);
      }
      engine.submitAnswer();

      // Final advance -> Complete!
      final isDone3 = engine.advanceOrComplete();
      expect(isDone3, true);
      expect(engine.phase, SpatialPatternPhase.sessionComplete);

      // Build final result
      final finalResult = engine.buildFinalResult();
      expect(finalResult.isCompleted, true);
      expect(finalResult.difficultyLevel, 1);
      expect(finalResult.score, greaterThan(70.0));
      expect(finalResult.nextDifficulty, isNotNull);
      expect(finalResult.reasonCode, isNotNull);
    });

    test('Local offline persistence integration with AppDatabase', () async {
      final db = AppDatabase();
      await db.initialize();

      final sessionModel = GameSessionModel(
        localId: 'loc_test_999',
        eventId: 'evt_test_999',
        patientId: 'patient_offline_01',
        gameType: 'spatial_pattern',
        difficultyLevel: 2,
        accuracy: 0.90,
        score: 90.0,
        errorCount: 1,
        hintsUsed: 0,
        durationMs: 12000,
        recommendationReason: 'HIGH_SUCCESS_RATE',
        occurredAt: DateTime.now(),
        syncStatus: 'PENDING',
      );

      await db.saveSession(sessionModel);

      final recent = await db.getRecentSessions();
      expect(recent.any((s) => s.localId == 'loc_test_999'), true);

      final pending = await db.getPendingSyncEvents();
      expect(pending.any((e) => e['event_id'] == 'evt_test_999'), true);
    });
  });
}

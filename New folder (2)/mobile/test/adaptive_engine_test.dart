import 'package:flutter_test/flutter_test.dart';
import 'package:smriti_mobile/domain/adaptive/adaptive_engine.dart';

void main() {
  group('MobileAdaptiveEngine Tier 0 Rules Test', () {
    test('Rule 1: Fatigue / Abandonment (<50% completion) steps down difficulty', () {
      final decision = MobileAdaptiveEngine.evaluate(
        currentDifficulty: 3,
        accuracy: 0.8,
        errorCount: 1,
        hintsUsed: 0,
        responseTimeMs: 3000,
        completionRate: 0.4,
      );
      expect(decision.nextDifficulty, equals(2));
      expect(decision.reasonCode, equals('FATIGUE_OR_ABANDONMENT'));
    });

    test('Rule 2: Low Accuracy (<60%) steps down difficulty to reduce frustration', () {
      final decision = MobileAdaptiveEngine.evaluate(
        currentDifficulty: 3,
        accuracy: 0.5,
        errorCount: 4,
        hintsUsed: 1,
        responseTimeMs: 3500,
        completionRate: 1.0,
      );
      expect(decision.nextDifficulty, equals(2));
      expect(decision.reasonCode, equals('LOW_ACCURACY'));
    });

    test('Rule 3: High Accuracy (>=85%) with consecutive successes advances difficulty', () {
      final decision = MobileAdaptiveEngine.evaluate(
        currentDifficulty: 2,
        accuracy: 0.95,
        errorCount: 0,
        hintsUsed: 0,
        responseTimeMs: 2000,
        consecutiveSuccesses: 1,
        completionRate: 1.0,
      );
      expect(decision.nextDifficulty, equals(3));
      expect(decision.reasonCode, equals('HIGH_SUCCESS_RATE'));
    });

    test('Rule 4: Stable Performance keeps difficulty unchanged', () {
      final decision = MobileAdaptiveEngine.evaluate(
        currentDifficulty: 2,
        accuracy: 0.75,
        errorCount: 2,
        hintsUsed: 0,
        responseTimeMs: 2800,
        consecutiveSuccesses: 0,
        completionRate: 1.0,
      );
      expect(decision.nextDifficulty, equals(2));
      expect(decision.reasonCode, equals('STABLE_PERFORMANCE'));
    });
  });
}

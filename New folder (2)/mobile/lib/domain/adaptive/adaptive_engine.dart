class AdaptiveDecision {
  final int nextDifficulty;
  final String reasonCode;
  final String userMessage;

  const AdaptiveDecision({
    required this.nextDifficulty,
    required this.reasonCode,
    required this.userMessage,
  });
}

class MobileAdaptiveEngine {
  /// Evaluates cognitive game performance signals and returns next difficulty.
  static AdaptiveDecision evaluate({
    required int currentDifficulty,
    required double accuracy,
    required int errorCount,
    required int hintsUsed,
    required int responseTimeMs,
    int consecutiveSuccesses = 0,
    int consecutiveFailures = 0,
    double completionRate = 1.0,
  }) {
    const int minDiff = 1;
    const int maxDiff = 10;

    // Rule 1: Abandonment / Severe difficulty -> step down
    if (completionRate < 0.50) {
      return AdaptiveDecision(
        nextDifficulty: (currentDifficulty > minDiff) ? currentDifficulty - 1 : minDiff,
        reasonCode: 'FATIGUE_OR_ABANDONMENT',
        userMessage: 'Let’s try a more relaxing pace for the next round.',
      );
    }

    // Rule 2: Low Accuracy (< 60%) -> step down
    if (accuracy < 0.60) {
      return AdaptiveDecision(
        nextDifficulty: (currentDifficulty > minDiff) ? currentDifficulty - 1 : minDiff,
        reasonCode: 'LOW_ACCURACY',
        userMessage: 'Great effort! We adjusted the difficulty so you can enjoy comfortably.',
      );
    }

    // Rule 3: High Accuracy (>= 85%) and consecutive successes -> step up
    if (accuracy >= 0.85 && consecutiveSuccesses >= 1) {
      return AdaptiveDecision(
        nextDifficulty: (currentDifficulty < maxDiff) ? currentDifficulty + 1 : maxDiff,
        reasonCode: 'HIGH_SUCCESS_RATE',
        userMessage: 'Splendid work! Ready for a gentle step forward?',
      );
    }

    // Rule 4: Stable Performance -> maintain current difficulty
    return AdaptiveDecision(
      nextDifficulty: currentDifficulty,
      reasonCode: 'STABLE_PERFORMANCE',
      userMessage: 'You are doing wonderfully well.',
    );
  }
}

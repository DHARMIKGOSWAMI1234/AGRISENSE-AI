class CognitiveScoringResult {
  final int totalTargets;
  final int correctCount;
  final int missedCount;
  final int incorrectCount;
  final double precision;
  final double recall;
  final double accuracy;
  final double score; // [0.0 - 100.0]
  final String feedbackMessage;

  const CognitiveScoringResult({
    required this.totalTargets,
    required this.correctCount,
    required this.missedCount,
    required this.incorrectCount,
    required this.precision,
    required this.recall,
    required this.accuracy,
    required this.score,
    required this.feedbackMessage,
  });
}

class CognitiveScoringEngine {
  /// Calculates standardized performance metrics for cognitive recognition & recall games.
  static CognitiveScoringResult calculateScore({
    required int totalTargets,
    required int correctCount,
    required int incorrectCount,
  }) {
    if (totalTargets <= 0) {
      return const CognitiveScoringResult(
        totalTargets: 0,
        correctCount: 0,
        missedCount: 0,
        incorrectCount: 0,
        precision: 0.0,
        recall: 0.0,
        accuracy: 0.0,
        score: 0.0,
        feedbackMessage: 'Great try!',
      );
    }

    final int missedCount = (totalTargets - correctCount).clamp(0, totalTargets);
    final int totalSelected = correctCount + incorrectCount;

    final double precision = (totalSelected > 0)
        ? (correctCount / totalSelected).clamp(0.0, 1.0)
        : 0.0;

    final double recall = (correctCount / totalTargets).clamp(0.0, 1.0);

    // Accuracy: Recall penalized for false alarm selections
    final double rawAccuracy = (correctCount - (0.5 * incorrectCount)) / totalTargets;
    final double accuracy = rawAccuracy.clamp(0.0, 1.0);

    // Normalized Score [0 - 100]
    final double score = (accuracy * 100.0).roundToDouble();

    // Elderly-friendly, encouraging feedback
    final String feedbackMessage;
    if (score >= 95.0) {
      feedbackMessage = 'Splendid! You remembered the entire pattern.';
    } else if (score >= 70.0) {
      feedbackMessage = 'Well done! Great visual recall.';
    } else if (score >= 40.0) {
      feedbackMessage = 'Good effort! Let’s look at the next pattern.';
    } else {
      feedbackMessage = 'That’s okay! We will take it step by step.';
    }

    return CognitiveScoringResult(
      totalTargets: totalTargets,
      correctCount: correctCount,
      missedCount: missedCount,
      incorrectCount: incorrectCount,
      precision: precision,
      recall: recall,
      accuracy: accuracy,
      score: score,
      feedbackMessage: feedbackMessage,
    );
  }
}

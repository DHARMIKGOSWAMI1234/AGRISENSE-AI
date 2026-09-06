import 'package:smriti_mobile/features/cognitive_games/domain/models/game_config.dart';
import 'package:smriti_mobile/features/cognitive_games/domain/models/game_type.dart';

export 'package:smriti_mobile/features/cognitive_games/domain/models/game_config.dart';
export 'package:smriti_mobile/features/cognitive_games/domain/models/game_type.dart';

class SpatialPatternDifficultyConfig extends CognitiveGameConfig {
  final int gridSize; // e.g. 3 for 3x3, 4 for 4x4, 5 for 5x5
  final int patternCellCount; // Number of illuminated pattern cells
  final int studyDurationMs; // Duration to memorize in ms
  final int? responseTimeLimitMs; // Optional limit (null = no time pressure)
  final String symbol; // Emoji or visual marker (e.g. '🔵', '⭐', '👒')

  const SpatialPatternDifficultyConfig({
    required super.difficultyLevel,
    required this.gridSize,
    required this.patternCellCount,
    this.studyDurationMs = 3500,
    this.responseTimeLimitMs,
    this.symbol = '🔵',
    super.roundCount = 3,
    super.hasTimePressure = false,
  }) : super(
          gameType: CognitiveGameType.spatialPattern,
        );

  int get totalCells => gridSize * gridSize;

  /// Factory producing standard clinical engineering ranges across 6 difficulty tiers.
  static SpatialPatternDifficultyConfig forLevel(int level) {
    switch (level) {
      case 1:
        return const SpatialPatternDifficultyConfig(
          difficultyLevel: 1,
          gridSize: 3,
          patternCellCount: 2,
          studyDurationMs: 4000,
          roundCount: 3,
          hasTimePressure: false,
        );
      case 2:
        return const SpatialPatternDifficultyConfig(
          difficultyLevel: 2,
          gridSize: 3,
          patternCellCount: 3,
          studyDurationMs: 3500,
          roundCount: 3,
          hasTimePressure: false,
        );
      case 3:
        return const SpatialPatternDifficultyConfig(
          difficultyLevel: 3,
          gridSize: 4,
          patternCellCount: 4,
          studyDurationMs: 3500,
          roundCount: 4,
          hasTimePressure: false,
        );
      case 4:
        return const SpatialPatternDifficultyConfig(
          difficultyLevel: 4,
          gridSize: 4,
          patternCellCount: 5,
          studyDurationMs: 3000,
          roundCount: 4,
          hasTimePressure: false,
        );
      case 5:
        return const SpatialPatternDifficultyConfig(
          difficultyLevel: 5,
          gridSize: 5,
          patternCellCount: 6,
          studyDurationMs: 3000,
          roundCount: 5,
          hasTimePressure: false,
        );
      case 6:
      default:
        return const SpatialPatternDifficultyConfig(
          difficultyLevel: 6,
          gridSize: 5,
          patternCellCount: 7,
          studyDurationMs: 2500,
          roundCount: 5,
          hasTimePressure: false,
        );
    }
  }
}

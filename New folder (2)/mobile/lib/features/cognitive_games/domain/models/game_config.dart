import 'game_type.dart';

abstract class CognitiveGameConfig {
  final CognitiveGameType gameType;
  final int difficultyLevel;
  final int roundCount;
  final bool hasTimePressure;

  const CognitiveGameConfig({
    required this.gameType,
    required this.difficultyLevel,
    this.roundCount = 3,
    this.hasTimePressure = false,
  });
}

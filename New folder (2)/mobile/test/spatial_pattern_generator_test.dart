import 'package:flutter_test/flutter_test.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/engine/spatial_pattern_generator.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/domain/spatial_pattern_config.dart';

void main() {
  group('SpatialPatternGenerator Tests', () {
    test('Pattern generator produces exact requested number of cells', () {
      for (int size = 3; size <= 5; size++) {
        for (int count = 2; count <= size * 2; count++) {
          final pattern = SpatialPatternGenerator.generatePattern(
            gridSize: size,
            cellCount: count,
          );
          expect(pattern.length, count, reason: 'Size: $size, Count: $count');
        }
      }
    });

    test('Pattern generator never produces duplicate cells', () {
      final pattern = SpatialPatternGenerator.generatePattern(
        gridSize: 4,
        cellCount: 6,
        seed: 42,
      );
      // Set guarantees uniqueness, length must equal cellCount
      expect(pattern.length, 6);
    });

    test('Pattern cells always fall inside grid bounds', () {
      const int gridSize = 4;
      for (int i = 0; i < 50; i++) {
        final pattern = SpatialPatternGenerator.generatePattern(
          gridSize: gridSize,
          cellCount: 5,
          seed: i * 17,
        );

        for (final coord in pattern) {
          expect(coord.row, greaterThanOrEqualTo(0));
          expect(coord.row, lessThan(gridSize));
          expect(coord.col, greaterThanOrEqualTo(0));
          expect(coord.col, lessThan(gridSize));
        }
      }
    });

    test('Seeded generation is strictly deterministic', () {
      const int seed = 9999;
      final pattern1 = SpatialPatternGenerator.generatePattern(
        gridSize: 4,
        cellCount: 5,
        seed: seed,
      );
      final pattern2 = SpatialPatternGenerator.generatePattern(
        gridSize: 4,
        cellCount: 5,
        seed: seed,
      );

      expect(pattern1, equals(pattern2));
    });

    test('Different seeds produce different patterns', () {
      final patternA = SpatialPatternGenerator.generatePattern(
        gridSize: 4,
        cellCount: 4,
        seed: 12345,
      );
      final patternB = SpatialPatternGenerator.generatePattern(
        gridSize: 4,
        cellCount: 4,
        seed: 54321,
      );

      expect(patternA, isNot(equals(patternB)));
    });

    test('All 6 difficulty configuration tiers load valid parameters', () {
      for (int level = 1; level <= 6; level++) {
        final config = SpatialPatternDifficultyConfig.forLevel(level);
        expect(config.difficultyLevel, level);
        expect(config.gridSize, greaterThanOrEqualTo(3));
        expect(config.gridSize, lessThanOrEqualTo(5));
        expect(config.patternCellCount, greaterThanOrEqualTo(2));
        expect(config.patternCellCount, lessThan(config.totalCells));
        expect(config.studyDurationMs, greaterThanOrEqualTo(2000));
        expect(config.roundCount, greaterThanOrEqualTo(3));
      }
    });
  });
}

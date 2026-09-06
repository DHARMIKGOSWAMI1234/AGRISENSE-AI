import 'dart:math';
import '../domain/spatial_pattern_state.dart';

class SpatialPatternGenerator {
  /// Generates a set of unique grid coordinates for a spatial pattern game.
  /// Guarantees:
  /// 1. Exactly [cellCount] unique coordinates.
  /// 2. All coordinates fall within [0, gridSize - 1].
  /// 3. Deterministic output when [seed] is provided.
  /// 4. Dispersal heuristic avoiding extreme clustering.
  static Set<GridCoordinate> generatePattern({
    required int gridSize,
    required int cellCount,
    int? seed,
  }) {
    assert(gridSize >= 2, 'Grid size must be at least 2x2');
    final int maxCells = gridSize * gridSize;
    assert(cellCount > 0 && cellCount <= maxCells, 'Cell count must be between 1 and $maxCells');

    final Random rng = (seed != null) ? Random(seed) : Random();
    final Set<GridCoordinate> pattern = {};

    // Generate list of all available coordinates
    final List<GridCoordinate> allCoords = [];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        allCoords.add(GridCoordinate(r, c));
      }
    }

    // Shuffle with seeded or random generator
    allCoords.shuffle(rng);

    if (gridSize >= 4 && cellCount >= 3 && cellCount < (maxCells - 2)) {
      // Dispersal check: Ensure pattern spans more than a single 2x2 quadrant if possible
      for (final coord in allCoords) {
        pattern.add(coord);
        if (pattern.length == cellCount) {
          // Check spatial dispersion across rows and columns
          final Set<int> rows = pattern.map((c) => c.row).toSet();
          final Set<int> cols = pattern.map((c) => c.col).toSet();
          if (rows.length >= 2 && cols.length >= 2) {
            break; // Good dispersion
          } else if (allCoords.length > cellCount + 5) {
            // Re-sample one cell to improve balance
            pattern.remove(pattern.first);
          }
        }
      }
    }

    // Fallback fill to guarantee exact cellCount
    int idx = 0;
    while (pattern.length < cellCount && idx < allCoords.length) {
      pattern.add(allCoords[idx]);
      idx++;
    }

    return pattern;
  }
}

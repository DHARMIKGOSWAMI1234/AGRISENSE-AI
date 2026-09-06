enum SpatialPatternPhase {
  intro,
  study,
  recall,
  feedback,
  roundComplete,
  sessionComplete,
}

class GridCoordinate {
  final int row;
  final int col;

  const GridCoordinate(this.row, this.col);

  int toIndex(int gridSize) => (row * gridSize) + col;

  static GridCoordinate fromIndex(int index, int gridSize) {
    return GridCoordinate(index ~/ gridSize, index % gridSize);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridCoordinate &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => '($row, $col)';
}

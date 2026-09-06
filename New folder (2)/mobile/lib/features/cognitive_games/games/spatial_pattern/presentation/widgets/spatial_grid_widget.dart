import 'package:flutter/material.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/domain/spatial_pattern_state.dart';
import 'pattern_cell_widget.dart';

class SpatialGridWidget extends StatelessWidget {
  final int gridSize;
  final SpatialPatternPhase phase;
  final Set<GridCoordinate> targetPattern;
  final Set<GridCoordinate> userSelection;
  final ValueChanged<GridCoordinate>? onCellTap;

  const SpatialGridWidget({
    super.key,
    required this.gridSize,
    required this.phase,
    required this.targetPattern,
    required this.userSelection,
    this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxAvailableWidth = constraints.maxWidth;
        final double maxAvailableHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : 400.0;
        final double availableSize = (maxAvailableWidth < maxAvailableHeight ? maxAvailableWidth : maxAvailableHeight) - 32;

        final double spacing = (gridSize >= 5) ? 8.0 : 12.0;
        final double totalSpacing = spacing * (gridSize - 1);
        final double rawCellSize = (availableSize - totalSpacing) / gridSize;
        final double cellSize = rawCellSize.clamp(56.0, 92.0);

        return Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(gridSize, (row) {
                return Padding(
                  padding: EdgeInsets.only(bottom: row < gridSize - 1 ? spacing : 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(gridSize, (col) {
                      final coord = GridCoordinate(row, col);
                      final bool isTarget = targetPattern.contains(coord);
                      final bool isSelected = userSelection.contains(coord);

                      return Padding(
                        padding: EdgeInsets.only(right: col < gridSize - 1 ? spacing : 0),
                        child: PatternCellWidget(
                          coordinate: coord,
                          phase: phase,
                          isTarget: isTarget,
                          isSelected: isSelected,
                          size: cellSize,
                          onTap: onCellTap != null ? () => onCellTap!(coord) : null,
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

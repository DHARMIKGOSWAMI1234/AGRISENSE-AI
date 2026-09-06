import 'package:flutter/material.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/domain/spatial_pattern_state.dart';

class PatternCellWidget extends StatelessWidget {
  final GridCoordinate coordinate;
  final SpatialPatternPhase phase;
  final bool isTarget;
  final bool isSelected;
  final VoidCallback? onTap;
  final double size;

  const PatternCellWidget({
    super.key,
    required this.coordinate,
    required this.phase,
    required this.isTarget,
    required this.isSelected,
    this.onTap,
    this.size = 72.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    Color backgroundColor;
    Color borderColor;
    double borderWidth = 2.0;

    switch (phase) {
      case SpatialPatternPhase.study:
        if (isTarget) {
          backgroundColor = const Color(0xFF0284C7); // Vibrant, clear cyan-blue
          borderColor = const Color(0xFF0369A1);
          content = Container(
            width: size * 0.55,
            height: size * 0.55,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.lens,
                color: Color(0xFF0284C7),
                size: 24,
              ),
            ),
          );
        } else {
          backgroundColor = const Color(0xFFF8FAFC);
          borderColor = const Color(0xFFCBD5E1);
          content = const SizedBox.shrink();
        }
        break;

      case SpatialPatternPhase.recall:
        if (isSelected) {
          backgroundColor = const Color(0xFFE0F2FE); // Soft blue selection
          borderColor = const Color(0xFF0284C7);
          borderWidth = 3.0;
          content = Container(
            width: size * 0.52,
            height: size * 0.52,
            decoration: const BoxDecoration(
              color: Color(0xFF0284C7),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 24,
              ),
            ),
          );
        } else {
          backgroundColor = Colors.white;
          borderColor = const Color(0xFFCBD5E1);
          content = const SizedBox.shrink();
        }
        break;

      case SpatialPatternPhase.feedback:
        if (isTarget && isSelected) {
          // Correctly recalled
          backgroundColor = const Color(0xFFDCFCE7); // Soft positive green
          borderColor = const Color(0xFF16A34A);
          borderWidth = 3.0;
          content = const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 32),
              SizedBox(height: 2),
              Text(
                'Correct',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF15803D),
                ),
              ),
            ],
          );
        } else if (isTarget && !isSelected) {
          // Missed target
          backgroundColor = const Color(0xFFFEF3C7); // Gentle amber
          borderColor = const Color(0xFFD97706);
          borderWidth = 2.5;
          content = const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.adjust_rounded, color: Color(0xFFB45309), size: 30),
              SizedBox(height: 2),
              Text(
                'Was here',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB45309),
                ),
              ),
            ],
          );
        } else if (!isTarget && isSelected) {
          // Incorrect selection (false alarm)
          backgroundColor = const Color(0xFFFFEDD5); // Soft neutral orange
          borderColor = const Color(0xFFEA580C);
          borderWidth = 2.0;
          content = const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFC2410C), size: 28),
              SizedBox(height: 2),
              Text(
                'Not here',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC2410C),
                ),
              ),
            ],
          );
        } else {
          // Neutral empty
          backgroundColor = const Color(0xFFF8FAFC);
          borderColor = const Color(0xFFE2E8F0);
          content = const SizedBox.shrink();
        }
        break;

      default:
        backgroundColor = Colors.white;
        borderColor = const Color(0xFFCBD5E1);
        content = const SizedBox.shrink();
        break;
    }

    final bool isTappable = (phase == SpatialPatternPhase.recall) && (onTap != null);

    return Semantics(
      label: 'Grid cell row ${coordinate.row + 1}, column ${coordinate.col + 1}. '
          '${isSelected ? "Selected." : "Not selected."} '
          '${isTarget && phase == SpatialPatternPhase.feedback ? "Was a pattern target." : ""}',
      button: isTappable,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isTappable ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0x330284C7),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}

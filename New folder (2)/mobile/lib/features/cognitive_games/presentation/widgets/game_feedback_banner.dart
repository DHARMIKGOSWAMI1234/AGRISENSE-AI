import 'package:flutter/material.dart';
import '../../engine/scoring_engine.dart';

class GameFeedbackBanner extends StatelessWidget {
  final CognitiveScoringResult scoringResult;
  final bool isLastRound;
  final VoidCallback onNextTap;

  const GameFeedbackBanner({
    super.key,
    required this.scoringResult,
    required this.isLastRound,
    required this.onNextTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHigh = scoringResult.score >= 70;
    final Color headerColor = isHigh ? const Color(0xFF15803D) : const Color(0xFF0369A1);
    final Color bgColor = isHigh ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE);
    final Color borderColor = isHigh ? const Color(0xFF86EFAC) : const Color(0xFFBAE6FD);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encouraging Message
          Row(
            children: [
              Icon(
                isHigh ? Icons.emoji_events_rounded : Icons.thumb_up_rounded,
                color: headerColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  scoringResult.feedbackMessage,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: headerColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Breakdown Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetricChip(
                label: 'Correct',
                value: '${scoringResult.correctCount}',
                color: const Color(0xFF16A34A),
                icon: Icons.check_circle_outline,
              ),
              _buildMetricChip(
                label: 'Missed',
                value: '${scoringResult.missedCount}',
                color: const Color(0xFFD97706),
                icon: Icons.info_outline,
              ),
              if (scoringResult.incorrectCount > 0)
                _buildMetricChip(
                  label: 'Extra',
                  value: '${scoringResult.incorrectCount}',
                  color: const Color(0xFFEA580C),
                  icon: Icons.help_outline,
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Primary Next Action Button
          ElevatedButton.icon(
            onPressed: onNextTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0369A1),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            icon: Icon(
              isLastRound ? Icons.stars_rounded : Icons.arrow_forward_rounded,
              size: 26,
            ),
            label: Text(
              isLastRound ? 'See Activity Summary' : 'Next Pattern',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

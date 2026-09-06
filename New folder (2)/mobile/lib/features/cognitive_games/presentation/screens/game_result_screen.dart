import 'package:flutter/material.dart';
import 'package:smriti_mobile/features/cognitive_games/domain/models/game_result.dart';

class GameResultScreen extends StatelessWidget {
  final CognitiveGameResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const GameResultScreen({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExcellent = result.score >= 80;
    final bool isGood = result.score >= 50;

    final Color badgeColor = isExcellent
        ? const Color(0xFF15803D)
        : (isGood ? const Color(0xFF0369A1) : const Color(0xFFB45309));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0369A1),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Activity Completed',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Celebratory Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      isExcellent ? '🌟' : '👏',
                      style: const TextStyle(fontSize: 54),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isExcellent
                          ? 'Splendid Effort!'
                          : (isGood ? 'Well Done!' : 'Great Practice!'),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.feedbackMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Performance Score Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Activity Score',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0369A1),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${result.score.round()} / 100',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0C4A6E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(result.accuracy * 100).round()}% Pattern Accuracy',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Detailed Performance Breakdown
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildSummaryRow(
                      icon: Icons.check_circle_rounded,
                      iconColor: const Color(0xFF16A34A),
                      label: 'Correct Recalls',
                      value: '${result.correctCount} / ${result.totalTargets}',
                    ),
                    const Divider(height: 20),
                    _buildSummaryRow(
                      icon: Icons.adjust_rounded,
                      iconColor: const Color(0xFFD97706),
                      label: 'Missed Cells',
                      value: '${result.missedCount}',
                    ),
                    if (result.incorrectCount > 0) ...[
                      const Divider(height: 20),
                      _buildSummaryRow(
                        icon: Icons.remove_circle_outline_rounded,
                        iconColor: const Color(0xFFEA580C),
                        label: 'Extra Selections',
                        value: '${result.incorrectCount}',
                      ),
                    ],
                    const Divider(height: 20),
                    _buildSummaryRow(
                      icon: Icons.layers_rounded,
                      iconColor: const Color(0xFF0284C7),
                      label: 'Completed Level',
                      value: 'Level ${result.difficultyLevel}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Adaptive Difficulty Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: Color(0xFF15803D), size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Next Activity Pace',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF15803D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Adjusted to Level ${result.nextDifficulty} based on your recent activity.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Offline Safe Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_done_outlined, color: Color(0xFF15803D), size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Session recorded offline and saved safely.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Buttons: Play Again / Return Home
              ElevatedButton.icon(
                onPressed: onPlayAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0369A1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.replay_rounded, size: 28),
                label: const Text(
                  'Play Another Round',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: onHome,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  side: const BorderSide(color: Color(0xFF0369A1), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.home_rounded, color: Color(0xFF0369A1), size: 26),
                label: const Text(
                  'Return to Home',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class GameHeaderWidget extends StatelessWidget {
  final String title;
  final int currentRound;
  final int totalRounds;
  final int difficultyLevel;
  final VoidCallback onHelpTap;
  final VoidCallback onExitTap;

  const GameHeaderWidget({
    super.key,
    required this.title,
    required this.currentRound,
    required this.totalRounds,
    required this.difficultyLevel,
    required this.onHelpTap,
    required this.onExitTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        children: [
          // Exit button
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 28, color: Color(0xFF0C4A6E)),
            tooltip: 'Return home',
            onPressed: onExitTap,
          ),
          const SizedBox(width: 8),

          // Title & round info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C4A6E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0369A1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Level $difficultyLevel',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Round $currentRound of $totalRounds',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Voice / Help button
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, size: 30, color: Color(0xFF0369A1)),
            tooltip: 'Repeat instructions',
            onPressed: onHelpTap,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smriti_mobile/localization/app_localizations.dart';
import 'package:smriti_mobile/features/games/memory_match/memory_match_screen.dart';
import 'package:smriti_mobile/features/games/routine_recall/routine_recall_screen.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/presentation/screens/spatial_pattern_game_screen.dart';

class GamesHomeScreen extends StatelessWidget {
  const GamesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0369A1),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Cognitive Activities',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.psychology_alt_rounded, color: Color(0xFF0369A1), size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Brain Exercises',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF0C4A6E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Gentle, engaging memory and attention activities.',
                            style: TextStyle(fontSize: 14, color: Color(0xFF0369A1)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 1. Flagship: Spatial Pattern Recognition
              _buildFeaturedActivityCard(
                context: context,
                badge: 'Recommended',
                emoji: '🔷',
                title: 'Spatial Pattern Recognition',
                subtitle: 'Train visual memory by recalling positions of highlighted circles on a calm grid.',
                difficultyBadge: 'Adaptive (Levels 1-6)',
                onPlay: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SpatialPatternGameScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              // 2. Memory Match
              _buildStandardActivityCard(
                context: context,
                emoji: '👒',
                title: loc.translate('memory_match_title'),
                subtitle: loc.translate('memory_match_desc'),
                onPlay: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MemoryMatchScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              // 3. Routine Recall
              _buildStandardActivityCard(
                context: context,
                emoji: '☕',
                title: loc.translate('routine_recall_title'),
                subtitle: loc.translate('routine_recall_desc'),
                onPlay: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RoutineRecallScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Offline Status Note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_done_outlined, color: Color(0xFF15803D), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        loc.translate('offline_status'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedActivityCard({
    required BuildContext context,
    required String badge,
    required String emoji,
    required String title,
    required String subtitle,
    required String difficultyBadge,
    required VoidCallback onPlay,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF0284C7), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  difficultyBadge,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C4A6E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475569),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0369A1),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              label: const Text(
                'Play Spatial Pattern',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardActivityCard({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onPlay,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 26)),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF0F172A)),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF0369A1), size: 20),
        onTap: onPlay,
      ),
    );
  }
}

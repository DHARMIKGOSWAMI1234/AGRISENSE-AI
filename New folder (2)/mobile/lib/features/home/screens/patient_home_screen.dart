import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../core/voice/tts_service.dart';
import '../../games/memory_match/memory_match_screen.dart';
import '../../games/routine_recall/routine_recall_screen.dart';
import '../../cognitive_games/presentation/games_home_screen.dart';
import '../../cognitive_games/games/spatial_pattern/presentation/screens/spatial_pattern_game_screen.dart';
import '../../reminders/screens/reminder_dialog.dart';

class PatientHomeScreen extends StatefulWidget {
  final Function(Locale) onLanguageChange;
  const PatientHomeScreen({super.key, required this.onLanguageChange});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final TTSService _tts = TTSService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakGreeting();
    });
  }

  void _speakGreeting() {
    final loc = AppLocalizations.of(context);
    _tts.speak(loc.translate('welcome_greeting'));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0369A1),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          loc.translate('app_name'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          // Voice Prompt Repeat Button
          IconButton(
            icon: const Icon(Icons.volume_up, size: 30),
            tooltip: loc.translate('repeat_instruction'),
            onPressed: _speakGreeting,
          ),
          // Language Switcher Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, size: 28),
            onSelected: (lang) {
              widget.onLanguageChange(Locale(lang));
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text('English (US/UK)')),
              const PopupMenuItem(value: 'as', child: Text('অসমীয়া (Assamese)')),
              const PopupMenuItem(value: 'hi', child: Text('हिन्दी (Hindi)')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Welcome Card
              Card(
                color: const Color(0xFFE0F2FE),
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny_rounded, color: Color(0xFF0369A1), size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              loc.translate('welcome_greeting'),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: const Color(0xFF0C4A6E),
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        loc.translate('sub_greeting'),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF0369A1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. Primary Recommended Activity Card (Spatial Pattern Recognition)
              Text(
                loc.translate('recommended_activity'),
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Color(0xFF0284C7), width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text('🔷', style: TextStyle(fontSize: 34)),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.translate('spatial_pattern_title'),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0369A1),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.translate('spatial_pattern_desc'),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SpatialPatternGameScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 28),
                        label: Text(loc.translate('start_activity')),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Additional Cognitive Activities
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'More Familiar Activities',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GamesHomeScreen()),
                      );
                    },
                    child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Memory Match Card
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: const Text('👒', style: TextStyle(fontSize: 32)),
                  title: Text(
                    loc.translate('memory_match_title'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(loc.translate('memory_match_desc')),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF0369A1)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MemoryMatchScreen()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Routine Recall Card
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: const Text('☕', style: TextStyle(fontSize: 32)),
                  title: Text(
                    loc.translate('routine_recall_title'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(loc.translate('routine_recall_desc')),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF0369A1)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RoutineRecallScreen()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Reminders Card Trigger
              Card(
                color: const Color(0xFFFEF3C7),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: const Icon(Icons.alarm_on_rounded, color: Color(0xFFB45309), size: 36),
                  title: Text(
                    loc.translate('reminder_header'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF78350F)),
                  ),
                  subtitle: const Text('Tap to view daily medication & water schedule'),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFB45309), size: 30),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ReminderDialog(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Offline Status Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Color(0xFF15803D), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        loc.translate('offline_status'),
                        style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w500),
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
}

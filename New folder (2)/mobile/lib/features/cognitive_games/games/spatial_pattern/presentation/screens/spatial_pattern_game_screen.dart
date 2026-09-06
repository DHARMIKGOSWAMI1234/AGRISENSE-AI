import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smriti_mobile/app/theme/elderly_theme.dart';
import 'package:smriti_mobile/core/voice/tts_service.dart';
import 'package:smriti_mobile/data/local/database/app_database.dart';
import 'package:smriti_mobile/data/models/game_session_model.dart';
import 'package:smriti_mobile/features/cognitive_games/domain/models/game_result.dart';
import 'package:smriti_mobile/features/cognitive_games/engine/scoring_engine.dart';
import 'package:smriti_mobile/features/cognitive_games/presentation/screens/game_intro_screen.dart';
import 'package:smriti_mobile/features/cognitive_games/presentation/screens/game_result_screen.dart';
import 'package:smriti_mobile/features/cognitive_games/presentation/widgets/game_feedback_banner.dart';
import 'package:smriti_mobile/features/cognitive_games/presentation/widgets/game_header.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/domain/spatial_pattern_config.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/domain/spatial_pattern_state.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/engine/spatial_pattern_engine.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/presentation/widgets/spatial_grid_widget.dart';

class SpatialPatternGameScreen extends StatefulWidget {
  final int initialDifficulty;
  final String patientId;

  const SpatialPatternGameScreen({
    super.key,
    this.initialDifficulty = 1,
    this.patientId = 'local_patient_001',
  });

  @override
  State<SpatialPatternGameScreen> createState() => _SpatialPatternGameScreenState();
}

class _SpatialPatternGameScreenState extends State<SpatialPatternGameScreen>
    with SingleTickerProviderStateMixin {
  late int _currentDifficulty;
  late SpatialPatternDifficultyConfig _config;
  late SpatialPatternEngine _engine;
  final TTSService _tts = TTSService();

  bool _showIntro = true;
  CognitiveScoringResult? _lastScoringResult;
  CognitiveGameResult? _finalResult;

  // Study timer and animation controller
  Timer? _studyTimer;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _currentDifficulty = widget.initialDifficulty;
    _initializeEngine();

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _config.studyDurationMs),
    );
  }

  void _initializeEngine() {
    _config = SpatialPatternDifficultyConfig.forLevel(_currentDifficulty);
    final String sessionId = 'sess_sp_${DateTime.now().millisecondsSinceEpoch}';
    _engine = SpatialPatternEngine(
      config: _config,
      patientId: widget.patientId,
      sessionId: sessionId,
    );
  }

  @override
  void dispose() {
    _studyTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  void _onStartGame() {
    setState(() {
      _showIntro = false;
      _finalResult = null;
      _lastScoringResult = null;
    });
    _startRound();
  }

  void _startRound() {
    _engine.startRound();
    _lastScoringResult = null;

    _progressController.duration = Duration(milliseconds: _config.studyDurationMs);
    _progressController.reset();
    _progressController.forward();

    _tts.speak('Look carefully at where the circles are.');

    setState(() {});

    _studyTimer?.cancel();
    _studyTimer = Timer(Duration(milliseconds: _config.studyDurationMs), () {
      if (mounted && _engine.phase == SpatialPatternPhase.study) {
        setState(() {
          _engine.transitionToRecall();
        });
        _tts.speak('Now tap the cells where you remember seeing the circles.');
      }
    });
  }

  void _onCellTap(GridCoordinate coord) {
    if (_engine.phase != SpatialPatternPhase.recall) return;
    setState(() {
      _engine.toggleCell(coord);
    });
  }

  void _onSubmitSelections() {
    if (_engine.phase != SpatialPatternPhase.recall) return;

    final scoring = _engine.submitAnswer();
    setState(() {
      _lastScoringResult = scoring;
    });

    _tts.speak(scoring.feedbackMessage);
  }

  void _onClearSelections() {
    if (_engine.phase != SpatialPatternPhase.recall) return;
    setState(() {
      for (final cell in _engine.userSelection.toList()) {
        _engine.toggleCell(cell);
      }
    });
  }

  Future<void> _onNextRoundOrComplete() async {
    final bool isSessionDone = _engine.advanceOrComplete();

    if (isSessionDone) {
      final result = _engine.buildFinalResult();

      // Persist session to local SQLite/AppDatabase offline
      final sessionModel = GameSessionModel(
        localId: 'local_${DateTime.now().millisecondsSinceEpoch}',
        eventId: 'evt_${result.sessionId}',
        patientId: widget.patientId,
        gameType: 'spatial_pattern',
        difficultyLevel: result.difficultyLevel,
        accuracy: result.accuracy,
        score: result.score,
        errorCount: result.incorrectCount + result.missedCount,
        hintsUsed: result.hintsUsed,
        durationMs: result.responseTimeMs + result.studyDurationMs,
        recommendationReason: result.reasonCode,
        occurredAt: result.occurredAt,
        syncStatus: 'PENDING',
      );

      await AppDatabase().saveSession(sessionModel);

      if (mounted) {
        setState(() {
          _finalResult = result;
        });
      }
    } else {
      _startRound();
    }
  }

  void _onPlayAgain() {
    final nextLevel = _finalResult?.nextDifficulty ?? _currentDifficulty;
    setState(() {
      _currentDifficulty = nextLevel;
      _initializeEngine();
      _showIntro = false;
      _finalResult = null;
      _lastScoringResult = null;
    });
    _startRound();
  }

  void _onExit() {
    _tts.stop();
    Navigator.of(context).pop();
  }

  void _speakCurrentPhaseHelp() {
    switch (_engine.phase) {
      case SpatialPatternPhase.study:
        _tts.speak('Look carefully at where the circles are placed on the grid.');
        break;
      case SpatialPatternPhase.recall:
        _tts.speak('Tap the boxes where the circles were, then press Submit Answers.');
        break;
      case SpatialPatternPhase.feedback:
        if (_lastScoringResult != null) {
          _tts.speak(_lastScoringResult!.feedbackMessage);
        }
        break;
      default:
        _tts.speak('Welcome to Spatial Pattern Recognition.');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Show Intro Screen
    if (_showIntro) {
      return GameIntroScreen(
        title: 'Spatial Pattern Recognition',
        subtitle: 'Engage and train visual memory by remembering positions on a calm grid.',
        iconEmoji: '🔷',
        difficultyLevel: _currentDifficulty,
        steps: const [
          'Look carefully at the highlighted circles on the grid.',
          'The circles will hide after a few calm seconds.',
          'Tap the boxes where you remember the circles were.',
          'Press Submit to see your friendly score.',
        ],
        onStart: _onStartGame,
        onBack: _onExit,
      );
    }

    // 2. Show Session Results Screen
    if (_finalResult != null) {
      return GameResultScreen(
        result: _finalResult!,
        onPlayAgain: _onPlayAgain,
        onHome: _onExit,
      );
    }

    // 3. Main Active Game View
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Game Header
              GameHeaderWidget(
                title: 'Spatial Pattern',
                currentRound: _engine.currentRound,
                totalRounds: _engine.totalRounds,
                difficultyLevel: _config.difficultyLevel,
                onHelpTap: _speakCurrentPhaseHelp,
                onExitTap: _onExit,
              ),

              const SizedBox(height: 16),

              // Phase Instruction Banner
              _buildPhaseBanner(),

              const SizedBox(height: 16),

              // Responsive Spatial Grid
              Expanded(
                child: Center(
                  child: SpatialGridWidget(
                    gridSize: _engine.gridSize,
                    phase: _engine.phase,
                    targetPattern: _engine.targetPattern,
                    userSelection: _engine.userSelection,
                    onCellTap: _onCellTap,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Action Controls or Feedback
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseBanner() {
    String message;
    IconData icon;
    Color color;

    switch (_engine.phase) {
      case SpatialPatternPhase.study:
        message = 'Look carefully at the pattern...';
        icon = Icons.visibility_rounded;
        color = const Color(0xFF0284C7);
        break;
      case SpatialPatternPhase.recall:
        message = 'Where were the ${_config.patternCellCount} circles? Tap to choose.';
        icon = Icons.touch_app_rounded;
        color = const Color(0xFF0C4A6E);
        break;
      case SpatialPatternPhase.feedback:
        message = 'Review your results:';
        icon = Icons.fact_check_rounded;
        color = const Color(0xFF15803D);
        break;
      default:
        message = 'Get ready...';
        icon = Icons.hourglass_top_rounded;
        color = const Color(0xFF0369A1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (_engine.phase == SpatialPatternPhase.study) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: 1.0 - _progressController.value,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    if (_engine.phase == SpatialPatternPhase.study) {
      return Container(
        height: 60,
        alignment: Alignment.center,
        child: const Text(
          'Memorizing pattern...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      );
    }

    if (_engine.phase == SpatialPatternPhase.recall) {
      final int selectedCount = _engine.userSelection.length;
      final int targetCount = _engine.targetCount;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selection counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Selected: $selectedCount of $targetCount circles',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
          ),
          Row(
            children: [
              if (selectedCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: OutlinedButton(
                    onPressed: _onClearSelections,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(80, ElderlyTheme.minTouchTargetSize),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: Color(0xFF94A3B8), width: 1.5),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                  ),
                ),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: selectedCount > 0 ? _onSubmitSelections : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0369A1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, ElderlyTheme.minTouchTargetSize),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 26),
                  label: const Text(
                    'Submit Answers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (_engine.phase == SpatialPatternPhase.feedback && _lastScoringResult != null) {
      final bool isLastRound = _engine.currentRound >= _engine.totalRounds;
      return GameFeedbackBanner(
        scoringResult: _lastScoringResult!,
        isLastRound: isLastRound,
        onNextTap: _onNextRoundOrComplete,
      );
    }

    return const SizedBox.shrink();
  }
}

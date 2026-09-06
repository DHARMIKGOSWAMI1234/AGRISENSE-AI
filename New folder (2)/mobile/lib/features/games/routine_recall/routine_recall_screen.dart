import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../localization/app_localizations.dart';
import '../../../core/voice/tts_service.dart';
import '../../../data/models/game_session_model.dart';
import '../../../data/local/database/app_database.dart';

class RoutineRecallScreen extends StatefulWidget {
  const RoutineRecallScreen({super.key});

  @override
  State<RoutineRecallScreen> createState() => _RoutineRecallScreenState();
}

class _RoutineRecallScreenState extends State<RoutineRecallScreen> {
  final TTSService _tts = TTSService();
  final AppDatabase _db = AppDatabase();

  final List<String> _targetRoutine = [
    'Wake up & drink warm water',
    'Morning Blood Pressure Medicine',
    'Nutritious breakfast & tea',
    'Gentle morning garden walk'
  ];

  late List<String> _shuffledSteps;
  int _currentStepIndex = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _shuffledSteps = List.from(_targetRoutine)..shuffle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.speak('Select the steps of your morning routine in the correct natural order.');
    });
  }

  void _onStepSelected(String step) {
    if (step == _targetRoutine[_currentStepIndex]) {
      setState(() {
        _currentStepIndex++;
        if (_currentStepIndex == _targetRoutine.length) {
          _isCompleted = true;
          _saveSession();
        }
      });
      _tts.speak('Correct step!');
    } else {
      _tts.speak('Think about what happens earlier in the morning.');
    }
  }

  void _saveSession() async {
    final session = GameSessionModel(
      localId: const Uuid().v4(),
      eventId: const Uuid().v4(),
      patientId: 'local_patient_001',
      gameType: 'routine_recall',
      difficultyLevel: 1,
      accuracy: 1.0,
      score: 10.0,
      errorCount: 0,
      hintsUsed: 0,
      durationMs: 25000,
      recommendationReason: 'HIGH_SUCCESS_RATE',
      occurredAt: DateTime.now(),
      syncStatus: 'PENDING',
    );
    await _db.saveSession(session);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    if (_isCompleted) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: Text('🌟', style: TextStyle(fontSize: 72))),
                const SizedBox(height: 16),
                const Text(
                  'Routine Recall Completed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'You arranged all morning routine steps in natural order.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 36),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.translate('return_home')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('routine_recall_title')),
        backgroundColor: const Color(0xFF0369A1),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Step ${_currentStepIndex + 1} of ${_targetRoutine.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
              ),
              const SizedBox(height: 6),
              const Text(
                'What is the next step in your morning routine?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: _shuffledSteps.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final step = _shuffledSteps[index];
                    final isAlreadyCompleted = _targetRoutine.indexOf(step) < _currentStepIndex;

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAlreadyCompleted ? const Color(0xFFDCFCE7) : Colors.white,
                        foregroundColor: isAlreadyCompleted ? const Color(0xFF15803D) : const Color(0xFF0F172A),
                        side: BorderSide(
                          color: isAlreadyCompleted ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      ),
                      onPressed: isAlreadyCompleted ? null : () => _onStepSelected(step),
                      child: Text(
                        step,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

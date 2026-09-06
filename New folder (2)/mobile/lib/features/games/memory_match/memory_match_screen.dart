import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../localization/app_localizations.dart';
import '../../../core/voice/tts_service.dart';
import '../../../data/models/game_session_model.dart';
import '../../../data/local/database/app_database.dart';
import '../../../domain/adaptive/adaptive_engine.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _CardItem {
  final String id;
  final String symbol;
  final String name;
  bool isFlipped = false;
  bool isMatched = false;

  _CardItem({
    required this.id,
    required this.symbol,
    required this.name,
  });
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  final TTSService _tts = TTSService();
  final AppDatabase _db = AppDatabase();
  final Stopwatch _stopwatch = Stopwatch();

  List<_CardItem> _cards = [];
  int? _firstSelectedIndex;
  bool _isProcessing = false;
  int _matchedPairs = 0;
  int _errors = 0;
  int _hintsUsed = 0;
  int _currentDifficulty = 1;
  bool _isCompleted = false;

  final List<Map<String, String>> _culturalArtifacts = [
    {'id': 'japi', 'symbol': '👒', 'name': 'Japi'},
    {'id': 'gamusa', 'symbol': '🧣', 'name': 'Gamusa'},
    {'id': 'sarai', 'symbol': '🏆', 'name': 'Xorai'},
    {'id': 'pitha', 'symbol': '🥟', 'name': 'Pitha'},
  ];

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    _stopwatch.reset();
    _stopwatch.start();
    _matchedPairs = 0;
    _errors = 0;
    _hintsUsed = 0;
    _isCompleted = false;
    _firstSelectedIndex = null;

    // 4 pairs (8 cards) for Level 1/2
    List<_CardItem> items = [];
    for (var artifact in _culturalArtifacts) {
      items.add(_CardItem(id: artifact['id']!, symbol: artifact['symbol']!, name: artifact['name']!));
      items.add(_CardItem(id: artifact['id']!, symbol: artifact['symbol']!, name: artifact['name']!));
    }
    items.shuffle();
    _cards = items;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.speak('Tap two cards to find matching pairs of traditional items.');
    });
  }

  void _onCardTap(int index) {
    if (_isProcessing || _cards[index].isFlipped || _cards[index].isMatched) {
      return;
    }

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      // Second card tapped
      _isProcessing = true;
      int firstIdx = _firstSelectedIndex!;
      _firstSelectedIndex = null;

      if (_cards[firstIdx].id == _cards[index].id) {
        // Matched
        setState(() {
          _cards[firstIdx].isMatched = true;
          _cards[index].isMatched = true;
          _matchedPairs++;
          _isProcessing = false;
        });
        _tts.speak('Great match!');

        if (_matchedPairs == _culturalArtifacts.length) {
          _onGameCompleted();
        }
      } else {
        // Mismatch
        _errors++;
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) {
            setState(() {
              _cards[firstIdx].isFlipped = false;
              _cards[index].isFlipped = false;
              _isProcessing = false;
            });
          }
        });
      }
    }
  }

  void _onGameCompleted() async {
    _stopwatch.stop();
    int durationMs = _stopwatch.elapsedMilliseconds;
    double accuracy = (_matchedPairs + _errors > 0)
        ? _matchedPairs / (_matchedPairs + _errors)
        : 1.0;

    // Calculate next adaptive difficulty
    final decision = MobileAdaptiveEngine.evaluate(
      currentDifficulty: _currentDifficulty,
      accuracy: accuracy,
      errorCount: _errors,
      hintsUsed: _hintsUsed,
      responseTimeMs: durationMs,
      consecutiveSuccesses: 1,
    );

    // Save session locally to SQLite
    final session = GameSessionModel(
      localId: const Uuid().v4(),
      eventId: const Uuid().v4(),
      patientId: 'local_patient_001',
      gameType: 'memory_match',
      difficultyLevel: _currentDifficulty,
      accuracy: accuracy,
      score: accuracy * 10,
      errorCount: _errors,
      hintsUsed: _hintsUsed,
      durationMs: durationMs,
      recommendationReason: decision.reasonCode,
      occurredAt: DateTime.now(),
      syncStatus: 'PENDING',
    );

    await _db.saveSession(session);

    setState(() {
      _isCompleted = true;
      _currentDifficulty = decision.nextDifficulty;
    });

    _tts.speak('Wonderful work! You matched all items successfully.');
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
                const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 72)),
                ),
                const SizedBox(height: 16),
                Text(
                  loc.translate('game_result_congrats'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                ),
                const SizedBox(height: 12),
                Text(
                  loc.translate('game_result_summary', params: {
                    'completed': '$_matchedPairs',
                    'total': '${_culturalArtifacts.length}'
                  }),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 36),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _setupGame();
                    });
                  },
                  child: Text(loc.translate('play_again')),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.translate('return_home'), style: const TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('memory_match_title')),
        backgroundColor: const Color(0xFF0369A1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, size: 28),
            onPressed: () {
              _hintsUsed++;
              _tts.speak('Look for matching shapes and tap them one after another.');
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Pairs Matched: $_matchedPairs / ${_culturalArtifacts.length}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0C4A6E)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    final isRevealed = card.isFlipped || card.isMatched;

                    return GestureDetector(
                      onTap: () => _onCardTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isRevealed
                              ? (card.isMatched ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE))
                              : const Color(0xFF0284C7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: card.isMatched ? const Color(0xFF16A34A) : const Color(0xFF0369A1),
                            width: 2.5,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                          ],
                        ),
                        child: Center(
                          child: isRevealed
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(card.symbol, style: const TextStyle(fontSize: 42)),
                                    const SizedBox(height: 4),
                                    Text(
                                      card.name,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                  ],
                                )
                              : const Icon(Icons.touch_app_rounded, size: 42, color: Colors.white),
                        ),
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

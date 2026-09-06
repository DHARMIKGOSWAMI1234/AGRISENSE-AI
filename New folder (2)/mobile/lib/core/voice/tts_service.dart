import 'package:flutter/foundation.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  bool isAvailable = true;
  double speechRate = 0.45; // Slower, calmer speech for elderly users
  double volume = 1.0;

  Future<void> speak(String text, {String languageCode = 'en'}) async {
    // In Flutter environment, logs spoken instruction or invokes TTS plugin with fallback
    debugPrint('[SMRITI TTS ($languageCode)] Speaking: "$text" (Rate: $speechRate)');
  }

  Future<void> stop() async {
    debugPrint('[SMRITI TTS] Stopped');
  }
}

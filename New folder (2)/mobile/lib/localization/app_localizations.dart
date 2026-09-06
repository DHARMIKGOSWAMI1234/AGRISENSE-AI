import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const Map<String, String> _defaultEnglish = {
    "app_name": "SMRITI",
    "tagline": "Cognitive Daily Companion",
    "welcome_greeting": "Good morning! Let's do one short memory activity together.",
    "sub_greeting": "You can pause or stop anytime.",
    "recommended_activity": "Today's Recommended Activity",
    "start_activity": "Start Activity",
    "memory_match_title": "Memory Match",
    "memory_match_desc": "Pair matching traditional objects and recall their positions.",
    "routine_recall_title": "Daily Routine Recall",
    "routine_recall_desc": "Arrange everyday steps in order: morning tea, medicine, and walks.",
    "pattern_title": "Pattern Recognition",
    "pattern_desc": "Discover visual rhythm sequences with familiar regional shapes.",
    "spatial_pattern_title": "Spatial Pattern Recognition",
    "spatial_pattern_desc": "Train visual memory by recalling positions of highlighted circles on a calm grid.",
    "spatial_pattern_instruction": "Look carefully at where the circles appear on the grid.",
    "spatial_pattern_ready": "Ready to Begin",
    "spatial_pattern_remember": "Where were the circles? Tap the cells you remember.",
    "spatial_pattern_submit": "Submit Selections",
    "spatial_pattern_good_try": "Good try! Let's look at the next pattern.",
    "spatial_pattern_next": "Next Pattern",
    "spatial_pattern_complete": "Activity Complete",
    "spatial_pattern_feedback_excellent": "Splendid! You remembered the entire pattern.",
    "spatial_pattern_feedback_good": "Well done! Great visual recall.",
    "spatial_pattern_feedback_try": "Good effort! Let's try the next pattern.",
    "spatial_pattern_feedback_easy": "That's okay! We will take it step by step.",
    "object_memory_title": "Remember the Objects",
    "object_memory_desc": "Observe regional household items and recall what was present.",
    "reminiscence_title": "Familiar Reminiscence",
    "reminiscence_desc": "Gentle recognition of family memories, places, and loved ones.",
    "reminder_header": "Daily Routine Reminder",
    "reminder_done": "Done",
    "reminder_later": "Remind Later",
    "reminder_skip": "Skip for Now",
    "game_result_congrats": "Wonderful effort!",
    "game_result_summary": "You completed {completed} of {total} items successfully.",
    "return_home": "Return Home",
    "play_again": "Try Another Round",
    "offline_status": "Offline Mode: Your activities are saved safely on this device.",
    "repeat_instruction": "Repeat Spoken Instruction",
    "language_selector": "Change Language",
    "text_size_selector": "Text Size"
  };

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (localizations != null) {
      return localizations;
    }
    final fallback = AppLocalizations(const Locale('en'));
    fallback._localizedStrings = Map.from(_defaultEnglish);
    return fallback;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings = Map.from(_defaultEnglish);

  Future<bool> load() async {
    try {
      final jsonString = await rootBundle.loadString('assets/i18n/${locale.languageCode}.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = {
        ..._defaultEnglish,
        ...jsonMap.map((key, value) => MapEntry(key, value.toString())),
      };
    } catch (_) {
      _localizedStrings = Map.from(_defaultEnglish);
    }
    return true;
  }

  String translate(String key, {Map<String, String>? params}) {
    String text = _localizedStrings[key] ?? _defaultEnglish[key] ?? key;
    if (params != null) {
      params.forEach((placeholder, value) {
        text = text.replaceAll('{$placeholder}', value);
      });
    }
    return text;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'as'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    final AppLocalizations localizations = AppLocalizations(locale);
    localizations.load();
    return SynchronousFuture<AppLocalizations>(localizations);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

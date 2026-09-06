import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/game_session_model.dart';
import '../../models/reminder_model.dart';

/// Local Database Layer (SQLite / In-Memory Interface for Offline-First Operation)
class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  final List<GameSessionModel> _sessions = [];
  final List<ReminderModel> _reminders = [];
  final List<Map<String, dynamic>> _syncQueue = [];

  Future<void> initialize() async {
    debugPrint('[SMRITI DB] Local database initialized successfully.');
    // Seed sample offline reminders
    if (_reminders.isEmpty) {
      _reminders.addAll([
        ReminderModel(
          id: 'rem_local_01',
          patientId: 'local_patient_001',
          reminderType: 'MEDICATION',
          title: 'Morning Blood Pressure Medication',
          scheduledTime: '08:30',
        ),
        ReminderModel(
          id: 'rem_local_02',
          patientId: 'local_patient_001',
          reminderType: 'HYDRATION',
          title: 'Warm Water / Tea',
          scheduledTime: '11:00',
        ),
        ReminderModel(
          id: 'rem_local_03',
          patientId: 'local_patient_001',
          reminderType: 'ACTIVITY',
          title: 'Daily Memory Stimulation Activity',
          scheduledTime: '16:00',
        ),
      ]);
    }
  }

  // --- Sessions Persistence ---
  Future<void> saveSession(GameSessionModel session) async {
    _sessions.insert(0, session);
    // Queue for sync
    _syncQueue.add({
      'event_id': session.eventId,
      'entity_type': 'game_session',
      'occurred_at': session.occurredAt.toIso8601String(),
      'payload': session.toMap(),
      'status': 'PENDING',
    });
    debugPrint('[SMRITI DB] Game session saved locally (${session.gameType}, score: ${session.score})');
  }

  Future<List<GameSessionModel>> getRecentSessions({int limit = 20}) async {
    return _sessions.take(limit).toList();
  }

  // --- Reminders ---
  Future<List<ReminderModel>> getReminders() async {
    return List.unmodifiable(_reminders);
  }

  // --- Sync Queue ---
  Future<List<Map<String, dynamic>>> getPendingSyncEvents() async {
    return _syncQueue.where((e) => e['status'] == 'PENDING').toList();
  }

  Future<void> markEventsSynced(List<String> eventIds) async {
    for (var evt in _syncQueue) {
      if (eventIds.contains(evt['event_id'])) {
        evt['status'] = 'SYNCED';
      }
    }
  }
}

class ReminderModel {
  final String id;
  final String patientId;
  final String reminderType; // 'MEDICATION', 'HYDRATION', 'ACTIVITY', 'APPOINTMENT'
  final String title;
  final String? description;
  final String scheduledTime; // 'HH:MM'
  final String recurrenceRule;
  final bool isActive;

  ReminderModel({
    required this.id,
    required this.patientId,
    required this.reminderType,
    required this.title,
    this.description,
    required this.scheduledTime,
    this.recurrenceRule = 'DAILY',
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'reminder_type': reminderType,
      'title': title,
      'description': description,
      'scheduled_time': scheduledTime,
      'recurrence_rule': recurrenceRule,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'],
      patientId: map['patient_id'],
      reminderType: map['reminder_type'],
      title: map['title'],
      description: map['description'],
      scheduledTime: map['scheduled_time'],
      recurrenceRule: map['recurrence_rule'],
      isActive: map['is_active'] == 1,
    );
  }
}

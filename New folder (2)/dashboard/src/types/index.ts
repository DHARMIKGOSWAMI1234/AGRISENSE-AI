export interface Patient {
  id: string;
  caregiver_id: string;
  display_name: string;
  age?: number;
  preferred_language: string;
  text_size_preset: string;
  voice_assistance_enabled: boolean;
  cultural_region_tag: string;
  created_at: string;
}

export interface GameSession {
  id: string;
  event_id: string;
  patient_id: string;
  game_type: string;
  difficulty_level: number;
  accuracy: number;
  score: number;
  error_count: number;
  hints_used: number;
  duration_ms: number;
  recommendation_reason?: string;
  occurred_at: string;
  synced_at: string;
}

export interface LongitudinalSummary {
  window_days: number;
  total_sessions: number;
  average_accuracy: number;
  average_duration_sec: number;
  preferred_game?: string;
  cognitive_engagement_index: number;
  trend_status: string;
  non_diagnostic_note: string;
}

export interface Reminder {
  id: string;
  patient_id: string;
  reminder_type: 'MEDICATION' | 'HYDRATION' | 'ACTIVITY' | 'APPOINTMENT';
  title: string;
  description?: string;
  scheduled_time: string;
  recurrence_rule: string;
  is_active: boolean;
}

export interface ActivityAlert {
  id: string;
  patient_id: string;
  alert_type: string;
  severity: 'INFO' | 'WARNING' | 'ATTENTION';
  title: string;
  message: string;
  is_acknowledged: boolean;
  created_at: string;
}

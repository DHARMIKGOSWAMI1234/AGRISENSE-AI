import { useState } from 'react';
import { Header } from './components/layout/Header';
import { Sidebar } from './components/layout/Sidebar';
import { OverviewTab } from './features/overview/OverviewTab';
import { TrendsTab } from './features/trends/TrendsTab';
import { RemindersTab } from './features/reminders/RemindersTab';
import { AlertsTab } from './features/alerts/AlertsTab';
import { LoginModal } from './features/auth/LoginModal';
import { Patient, GameSession, LongitudinalSummary, Reminder, ActivityAlert } from './types';

export function App() {
  const [authToken, setAuthToken] = useState<string | null>(localStorage.getItem('smriti_token'));
  const [activeTab, setActiveTab] = useState<string>('overview');

  // Active Patient State
  const [currentPatient] = useState<Patient>({
    id: 'pat_001',
    caregiver_id: 'usr_caregiver_001',
    display_name: 'Minoti Bordoloi',
    age: 74,
    preferred_language: 'as', // Assamese
    text_size_preset: 'Large',
    voice_assistance_enabled: true,
    cultural_region_tag: 'NER_ASSAM',
    created_at: new Date().toISOString()
  });

  const [sessions] = useState<GameSession[]>([
    {
      id: 'sess_01',
      event_id: 'evt_uuid_001',
      patient_id: 'pat_001',
      game_type: 'memory_match',
      difficulty_level: 2,
      accuracy: 0.88,
      score: 8.8,
      error_count: 1,
      hints_used: 1,
      duration_ms: 45000,
      recommendation_reason: 'HIGH_SUCCESS_RATE',
      occurred_at: new Date(Date.now() - 3600000).toISOString(),
      synced_at: new Date().toISOString()
    },
    {
      id: 'sess_02',
      event_id: 'evt_uuid_002',
      patient_id: 'pat_001',
      game_type: 'routine_recall',
      difficulty_level: 1,
      accuracy: 0.95,
      score: 9.5,
      error_count: 0,
      hints_used: 0,
      duration_ms: 32000,
      recommendation_reason: 'HIGH_SUCCESS_RATE',
      occurred_at: new Date(Date.now() - 7200000).toISOString(),
      synced_at: new Date().toISOString()
    }
  ]);

  const [summary] = useState<LongitudinalSummary>({
    window_days: 7,
    total_sessions: 6,
    average_accuracy: 0.89,
    average_duration_sec: 28.5,
    preferred_game: 'memory_match',
    cognitive_engagement_index: 87.2,
    trend_status: 'CONSISTENT',
    non_diagnostic_note: 'Shows cognitive activity engagement. Not a medical dementia assessment.'
  });

  const [reminders, setReminders] = useState<Reminder[]>([
    {
      id: 'rem_01',
      patient_id: 'pat_001',
      reminder_type: 'MEDICATION',
      title: 'Morning Blood Pressure Medication',
      scheduled_time: '08:30',
      recurrence_rule: 'DAILY',
      is_active: true
    },
    {
      id: 'rem_02',
      patient_id: 'pat_001',
      reminder_type: 'HYDRATION',
      title: 'Mid-Morning Water / Warm Tea',
      scheduled_time: '11:00',
      recurrence_rule: 'DAILY',
      is_active: true
    },
    {
      id: 'rem_03',
      patient_id: 'pat_001',
      reminder_type: 'ACTIVITY',
      title: 'Afternoon Memory Activity with SMRITI',
      scheduled_time: '16:00',
      recurrence_rule: 'DAILY',
      is_active: true
    }
  ]);

  const [alerts, setAlerts] = useState<ActivityAlert[]>([
    {
      id: 'alt_01',
      patient_id: 'pat_001',
      alert_type: 'INACTIVITY',
      severity: 'INFO',
      title: 'Daily Activity Completed',
      message: 'Minoti successfully completed today’s Memory Match activity (Level 2).',
      is_acknowledged: false,
      created_at: new Date().toISOString()
    }
  ]);

  const handleLogin = (token: string, _user: any) => {
    localStorage.setItem('smriti_token', token);
    setAuthToken(token);
  };

  const handleLogout = () => {
    localStorage.removeItem('smriti_token');
    setAuthToken(null);
  };

  const handleCreateReminder = (remData: Partial<Reminder>) => {
    const newRem: Reminder = {
      id: `rem_${Date.now()}`,
      patient_id: currentPatient.id,
      reminder_type: remData.reminder_type as any || 'MEDICATION',
      title: remData.title || '',
      scheduled_time: remData.scheduled_time || '09:00',
      recurrence_rule: 'DAILY',
      is_active: true
    };
    setReminders([...reminders, newRem]);
  };

  const handleAcknowledgeAlert = (alertId: string) => {
    setAlerts(alerts.map(a => a.id === alertId ? { ...a, is_acknowledged: true } : a));
  };

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col font-sans">
      {!authToken && <LoginModal onLogin={handleLogin} />}

      <Header
        currentPatient={currentPatient}
        onLogout={handleLogout}
        syncStatus="synced"
        lastSyncTime="2 mins ago"
      />

      <div className="flex flex-1">
        <Sidebar
          activeTab={activeTab}
          setActiveTab={setActiveTab}
          alertCount={alerts.filter(a => !a.is_acknowledged).length}
        />

        <main className="flex-1 p-8 overflow-y-auto max-w-7xl">
          {activeTab === 'overview' && (
            <OverviewTab
              patient={currentPatient}
              sessions={sessions}
              summary={summary}
            />
          )}

          {activeTab === 'trends' && (
            <TrendsTab
              sessions={sessions}
              summary={summary}
            />
          )}

          {activeTab === 'reminders' && (
            <RemindersTab
              reminders={reminders}
              onCreateReminder={handleCreateReminder}
            />
          )}

          {activeTab === 'alerts' && (
            <AlertsTab
              alerts={alerts}
              onAcknowledge={handleAcknowledgeAlert}
            />
          )}

          {activeTab === 'patients' && (
            <div className="bg-white p-6 rounded-xl border border-slate-200">
              <h3 className="text-lg font-bold text-slate-800 mb-2">Patient Profiles & Cultural Settings</h3>
              <p className="text-xs text-slate-500 mb-6">Assigned elderly patients in your caregiver circle.</p>
              <div className="p-4 rounded-xl bg-slate-50 border border-slate-200 max-w-md">
                <div className="font-bold text-slate-800 text-sm">{currentPatient.display_name}</div>
                <div className="text-xs text-slate-500 mt-1">Age: {currentPatient.age} | Region: {currentPatient.cultural_region_tag}</div>
                <div className="text-xs text-sky-700 font-semibold mt-2">Language: Assamese (অসমীয়া) | Text Size: {currentPatient.text_size_preset}</div>
              </div>
            </div>
          )}
        </main>
      </div>
    </div>
  );
}

export default App;

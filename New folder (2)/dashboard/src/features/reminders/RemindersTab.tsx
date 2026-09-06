import React, { useState } from 'react';
import { Plus, Pill, Droplet, Sun, Clock } from 'lucide-react';
import { Reminder } from '../../types';

interface RemindersTabProps {
  reminders: Reminder[];
  onCreateReminder: (reminder: Partial<Reminder>) => void;
}

export const RemindersTab: React.FC<RemindersTabProps> = ({ reminders, onCreateReminder }) => {
  const [showModal, setShowModal] = useState(false);
  const [newTitle, setNewTitle] = useState('');
  const [newType, setNewType] = useState<'MEDICATION' | 'HYDRATION' | 'ACTIVITY'>('MEDICATION');
  const [newTime, setNewTime] = useState('09:00');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTitle) return;
    onCreateReminder({
      title: newTitle,
      reminder_type: newType,
      scheduled_time: newTime,
      recurrence_rule: 'DAILY',
      is_active: true
    });
    setNewTitle('');
    setShowModal(false);
  };

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'MEDICATION': return <Pill className="w-5 h-5 text-rose-500" />;
      case 'HYDRATION': return <Droplet className="w-5 h-5 text-sky-500" />;
      default: return <Sun className="w-5 h-5 text-amber-500" />;
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
        <div>
          <h3 className="text-base font-bold text-slate-800">Daily Routines & Caregiver Reminders</h3>
          <p className="text-xs text-slate-500 mt-0.5">Schedules are synchronized locally to the patient's mobile app for offline prompting.</p>
        </div>
        <button
          onClick={() => setShowModal(true)}
          className="flex items-center space-x-2 px-4 py-2 bg-sky-600 hover:bg-sky-700 text-white rounded-xl text-xs font-semibold shadow-sm transition-colors"
        >
          <Plus className="w-4 h-4" />
          <span>Add Reminder</span>
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
        {reminders.map((r) => (
          <div key={r.id} className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex items-start justify-between">
            <div className="flex items-start space-x-3.5">
              <div className="p-2.5 rounded-xl bg-slate-50 border border-slate-100">
                {getTypeIcon(r.reminder_type)}
              </div>
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                  {r.reminder_type}
                </span>
                <h4 className="font-bold text-slate-800 text-sm mt-0.5">{r.title}</h4>
                <div className="flex items-center space-x-2 text-xs text-slate-500 mt-2">
                  <Clock className="w-3.5 h-3.5 text-slate-400" />
                  <span>Scheduled: {r.scheduled_time} ({r.recurrence_rule})</span>
                </div>
              </div>
            </div>
            <span className="px-2 py-0.5 text-[10px] font-semibold rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200">
              Active
            </span>
          </div>
        ))}
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-xl">
            <h3 className="text-lg font-bold text-slate-800 mb-4">Configure Caregiver Reminder</h3>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-600 mb-1">Reminder Title</label>
                <input
                  type="text"
                  placeholder="e.g. Morning Blood Pressure Tablet & Water"
                  value={newTitle}
                  onChange={(e) => setNewTitle(e.target.value)}
                  className="w-full px-3 py-2 text-sm border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-sky-500"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-600 mb-1">Category</label>
                <select
                  value={newType}
                  onChange={(e) => setNewType(e.target.value as any)}
                  className="w-full px-3 py-2 text-sm border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-sky-500"
                >
                  <option value="MEDICATION">Medication</option>
                  <option value="HYDRATION">Hydration</option>
                  <option value="ACTIVITY">Daily Routine Walk/Activity</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-600 mb-1">Scheduled Time (24h)</label>
                <input
                  type="time"
                  value={newTime}
                  onChange={(e) => setNewTime(e.target.value)}
                  className="w-full px-3 py-2 text-sm border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-sky-500"
                  required
                />
              </div>

              <div className="flex justify-end space-x-3 pt-3">
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="px-4 py-2 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-lg"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-xs font-semibold text-white bg-sky-600 hover:bg-sky-700 rounded-lg shadow-sm"
                >
                  Save Reminder
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

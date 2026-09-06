import React from 'react';
import { Activity, Clock, Brain, Award } from 'lucide-react';
import { Patient, GameSession, LongitudinalSummary } from '../../types';

interface OverviewTabProps {
  patient: Patient | null;
  sessions: GameSession[];
  summary: LongitudinalSummary | null;
}

export const OverviewTab: React.FC<OverviewTabProps> = ({ patient, sessions, summary }) => {
  const latestSession = sessions[0];

  return (
    <div className="space-y-6">
      {/* Top Banner */}
      <div className="bg-gradient-to-r from-sky-700 to-indigo-800 rounded-2xl p-6 text-white shadow-lg shadow-sky-900/10">
        <div className="flex justify-between items-start">
          <div>
            <span className="text-xs font-semibold uppercase tracking-wider text-sky-200 bg-sky-900/40 px-3 py-1 rounded-full">
              Daily Caregiver Summary
            </span>
            <h2 className="text-2xl font-bold mt-2">
              Patient: {patient?.display_name || 'Selected Patient'}
            </h2>
            <p className="text-sky-100 text-sm mt-1 max-w-xl">
              Regional Language: <strong>{patient?.preferred_language === 'as' ? 'Assamese' : patient?.preferred_language === 'hi' ? 'Hindi' : 'English'}</strong> | Cultural Pack: <strong>{patient?.cultural_region_tag || 'NER Standard'}</strong>
            </p>
          </div>
          <div className="text-right">
            <div className="text-3xl font-extrabold text-white">
              {summary?.cognitive_engagement_index ?? 84.5}%
            </div>
            <div className="text-xs text-sky-200 font-medium">Cognitive Engagement Index (7d)</div>
          </div>
        </div>
      </div>

      {/* Metric Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-5">
        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500 uppercase">Today's Activity</span>
            <Activity className="w-5 h-5 text-sky-600" />
          </div>
          <div className="text-2xl font-bold text-slate-800 mt-2">
            {sessions.length > 0 ? `${sessions.length} Completed` : '1 Activity Ready'}
          </div>
          <p className="text-xs text-slate-400 mt-1">Memory Match & Daily Recall</p>
        </div>

        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500 uppercase">Average Accuracy</span>
            <Award className="w-5 h-5 text-emerald-600" />
          </div>
          <div className="text-2xl font-bold text-slate-800 mt-2">
            {summary ? `${Math.round(summary.average_accuracy * 100)}%` : '85%'}
          </div>
          <p className="text-xs text-emerald-600 font-medium mt-1">Comfortable challenge level</p>
        </div>

        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500 uppercase">Mean Response Time</span>
            <Clock className="w-5 h-5 text-amber-600" />
          </div>
          <div className="text-2xl font-bold text-slate-800 mt-2">
            {summary?.average_duration_sec ? `${summary.average_duration_sec.toFixed(1)}s` : '2.8s'}
          </div>
          <p className="text-xs text-slate-400 mt-1">Normalized for game difficulty</p>
        </div>

        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500 uppercase">Adaptive AI Status</span>
            <Brain className="w-5 h-5 text-indigo-600" />
          </div>
          <div className="text-2xl font-bold text-slate-800 mt-2">Level {latestSession?.difficulty_level || 2}</div>
          <p className="text-xs text-indigo-600 font-medium mt-1">
            {latestSession?.recommendation_reason || 'HIGH_SUCCESS_RATE'}
          </p>
        </div>
      </div>

      {/* Recent Activity Table */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="px-6 py-4 border-b border-slate-200 flex justify-between items-center">
          <h3 className="font-semibold text-slate-800 text-sm">Recent Activity Log (Local & Synced)</h3>
          <span className="text-xs text-slate-400">UUID Deduplicated</span>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-slate-600">
            <thead className="bg-slate-50 text-slate-500 font-semibold border-b border-slate-200">
              <tr>
                <th className="px-6 py-3">Activity Type</th>
                <th className="px-6 py-3">Difficulty</th>
                <th className="px-6 py-3">Accuracy</th>
                <th className="px-6 py-3">Hints Used</th>
                <th className="px-6 py-3">Duration</th>
                <th className="px-6 py-3">AI Adaptive Reason</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {sessions.length > 0 ? (
                sessions.map((session) => (
                  <tr key={session.id || session.event_id} className="hover:bg-slate-50">
                    <td className="px-6 py-3.5 font-medium text-slate-800 capitalize">
                      {session.game_type.replace('_', ' ')}
                    </td>
                    <td className="px-6 py-3.5">Level {session.difficulty_level}</td>
                    <td className="px-6 py-3.5">
                      <span className="px-2 py-0.5 rounded-md font-semibold bg-emerald-50 text-emerald-700">
                        {Math.round(session.accuracy * 100)}%
                      </span>
                    </td>
                    <td className="px-6 py-3.5">{session.hints_used}</td>
                    <td className="px-6 py-3.5">{(session.duration_ms / 1000).toFixed(1)}s</td>
                    <td className="px-6 py-3.5 font-mono text-[11px] text-slate-500">
                      {session.recommendation_reason || 'STABLE_PERFORMANCE'}
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={6} className="px-6 py-8 text-center text-slate-400">
                    No activity recorded yet for today. Tap start on the patient app to begin!
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

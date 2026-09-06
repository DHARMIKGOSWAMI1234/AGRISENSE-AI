import React from 'react';
import { ResponsiveContainer, LineChart, Line, XAxis, YAxis, Tooltip, CartesianGrid, BarChart, Bar } from 'recharts';
import { GameSession, LongitudinalSummary } from '../../types';

interface TrendsTabProps {
  sessions: GameSession[];
  summary?: LongitudinalSummary | null;
}

export const TrendsTab: React.FC<TrendsTabProps> = ({ sessions }) => {
  // Generate sample trend data points if empty
  const chartData = sessions.length > 0
    ? [...sessions].reverse().map((s, idx) => ({
        name: `Session ${idx + 1}`,
        accuracy: Math.round(s.accuracy * 100),
        duration: Math.round(s.duration_ms / 1000),
        difficulty: s.difficulty_level,
      }))
    : [
        { name: 'Mon', accuracy: 80, duration: 32, difficulty: 1 },
        { name: 'Tue', accuracy: 85, duration: 28, difficulty: 1 },
        { name: 'Wed', accuracy: 90, duration: 26, difficulty: 2 },
        { name: 'Thu', accuracy: 78, duration: 30, difficulty: 2 },
        { name: 'Fri', accuracy: 88, duration: 25, difficulty: 2 },
        { name: 'Sat', accuracy: 92, duration: 22, difficulty: 3 },
        { name: 'Sun', accuracy: 95, duration: 20, difficulty: 3 },
      ];

  return (
    <div className="space-y-6">
      <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
        <div className="flex justify-between items-center mb-6">
          <div>
            <h3 className="text-base font-bold text-slate-800">Longitudinal Accuracy Trend (7-Day Window)</h3>
            <p className="text-xs text-slate-500 mt-0.5">Observational engagement performance. Shows cognitive stimulation trajectory.</p>
          </div>
          <span className="px-3 py-1 bg-sky-50 text-sky-700 text-xs font-semibold rounded-full border border-sky-100">
            Window: 7 Days
          </span>
        </div>

        <div className="h-72 w-full">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={chartData} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="name" stroke="#94a3b8" fontSize={12} />
              <YAxis stroke="#94a3b8" fontSize={12} domain={[50, 100]} />
              <Tooltip />
              <Line type="monotone" dataKey="accuracy" stroke="#0284c7" strokeWidth={3} dot={{ fill: '#0284c7', r: 4 }} activeDot={{ r: 6 }} name="Accuracy (%)" />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
          <h3 className="text-base font-bold text-slate-800 mb-1">Response Time Calibration (Seconds)</h3>
          <p className="text-xs text-slate-500 mb-4">Duration to complete game interactions.</p>
          <div className="h-60 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="name" stroke="#94a3b8" fontSize={12} />
                <YAxis stroke="#94a3b8" fontSize={12} />
                <Tooltip />
                <Bar dataKey="duration" fill="#f59e0b" radius={[4, 4, 0, 0]} name="Response Time (s)" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
          <h3 className="text-base font-bold text-slate-800 mb-1">Adaptive Difficulty Level Progression</h3>
          <p className="text-xs text-slate-500 mb-4">Dynamic progression managed by Explainable AI rules.</p>
          <div className="h-60 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="name" stroke="#94a3b8" fontSize={12} />
                <YAxis stroke="#94a3b8" fontSize={12} domain={[1, 5]} />
                <Tooltip />
                <Line type="stepAfter" dataKey="difficulty" stroke="#6366f1" strokeWidth={2.5} dot={{ fill: '#6366f1', r: 4 }} name="Difficulty Level" />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </div>
  );
};

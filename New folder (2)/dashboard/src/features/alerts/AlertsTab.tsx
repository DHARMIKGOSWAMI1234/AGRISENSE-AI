import React from 'react';
import { CheckCircle, ShieldAlert } from 'lucide-react';
import { ActivityAlert } from '../../types';

interface AlertsTabProps {
  alerts: ActivityAlert[];
  onAcknowledge: (alertId: string) => void;
}

export const AlertsTab: React.FC<AlertsTabProps> = ({ alerts, onAcknowledge }) => {
  return (
    <div className="space-y-6">
      <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
        <h3 className="text-base font-bold text-slate-800">Caregiver Activity Alerts</h3>
        <p className="text-xs text-slate-500 mt-0.5">
          Actionable, non-diagnostic alerts for prolonged inactivity or sync anomalies.
        </p>
      </div>

      <div className="space-y-3">
        {alerts.length > 0 ? (
          alerts.map((alert) => (
            <div
              key={alert.id}
              className={`p-4 rounded-xl border flex items-start justify-between ${
                alert.is_acknowledged
                  ? 'bg-slate-50 border-slate-200 opacity-60'
                  : 'bg-white border-amber-200 shadow-sm'
              }`}
            >
              <div className="flex items-start space-x-3.5">
                <div className="p-2 rounded-lg bg-amber-50 text-amber-600 mt-0.5">
                  <ShieldAlert className="w-5 h-5" />
                </div>
                <div>
                  <div className="flex items-center space-x-2">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-amber-700 bg-amber-100 px-2 py-0.5 rounded-full">
                      {alert.severity}
                    </span>
                    <span className="text-xs text-slate-400">
                      {new Date(alert.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </span>
                  </div>
                  <h4 className="font-bold text-slate-800 text-sm mt-1">{alert.title}</h4>
                  <p className="text-xs text-slate-600 mt-0.5">{alert.message}</p>
                </div>
              </div>

              {!alert.is_acknowledged && (
                <button
                  onClick={() => onAcknowledge(alert.id)}
                  className="text-xs font-semibold px-3 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 text-slate-700 transition-colors"
                >
                  Acknowledge
                </button>
              )}
            </div>
          ))
        ) : (
          <div className="bg-white p-12 text-center rounded-xl border border-slate-200 text-slate-400">
            <CheckCircle className="w-8 h-8 mx-auto text-emerald-500 mb-2" />
            <p className="text-sm font-medium text-slate-700">All Systems Clear</p>
            <p className="text-xs text-slate-400 mt-1">No active engagement alerts or prolonged inactivity detected.</p>
          </div>
        )}
      </div>
    </div>
  );
};

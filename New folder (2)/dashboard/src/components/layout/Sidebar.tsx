import React from 'react';
import { LayoutDashboard, TrendingUp, Calendar, AlertCircle, Users } from 'lucide-react';

interface SidebarProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
  alertCount: number;
}

export const Sidebar: React.FC<SidebarProps> = ({ activeTab, setActiveTab, alertCount }) => {
  const navItems = [
    { id: 'overview', label: 'Activity Overview', icon: LayoutDashboard },
    { id: 'trends', label: 'Cognitive Trends', icon: TrendingUp },
    { id: 'reminders', label: 'Routine & Reminders', icon: Calendar },
    { id: 'alerts', label: 'Activity Alerts', icon: AlertCircle, count: alertCount },
    { id: 'patients', label: 'Patient Profiles', icon: Users },
  ];

  return (
    <aside className="w-64 bg-white border-r border-slate-200 min-h-[calc(100vh-73px)] p-4 flex flex-col justify-between">
      <nav className="space-y-1.5">
        <div className="text-xs font-semibold uppercase tracking-wider text-slate-400 px-3 py-2">
          Caregiver Views
        </div>
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;
          return (
            <button
              key={item.id}
              onClick={() => setActiveTab(item.id)}
              className={`w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl text-sm font-medium transition-all ${
                isActive
                  ? 'bg-sky-50 text-sky-700 shadow-sm border border-sky-100'
                  : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
              }`}
            >
              <div className="flex items-center space-x-3">
                <Icon className={`w-4 h-4 ${isActive ? 'text-sky-600' : 'text-slate-400'}`} />
                <span>{item.label}</span>
              </div>
              {item.count !== undefined && item.count > 0 && (
                <span className="px-2 py-0.5 text-xs font-semibold rounded-full bg-amber-100 text-amber-800">
                  {item.count}
                </span>
              )}
            </button>
          );
        })}
      </nav>

      <div className="pt-4 border-t border-slate-100 text-xs text-slate-400 px-3">
        <div className="font-semibold text-slate-600 mb-1">Non-Diagnostic Mode</div>
        <p className="leading-relaxed">All charts show observed cognitive engagement. Not a clinical dementia diagnosis.</p>
      </div>
    </aside>
  );
};

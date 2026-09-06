import React from 'react';
import { Heart, Wifi, User as UserIcon } from 'lucide-react';
import { Patient } from '../../types';

interface HeaderProps {
  currentPatient: Patient | null;
  onLogout: () => void;
  syncStatus?: 'synced' | 'syncing' | 'offline';
  lastSyncTime?: string;
}

export const Header: React.FC<HeaderProps> = ({ currentPatient, onLogout, syncStatus = 'synced', lastSyncTime = 'Just now' }) => {
  return (
    <header className="bg-white border-b border-slate-200 px-6 py-4 flex items-center justify-between shadow-sm">
      <div className="flex items-center space-x-3">
        <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-sky-600 to-indigo-600 flex items-center justify-center text-white shadow-md shadow-sky-500/20">
          <Heart className="w-5 h-5 fill-current" />
        </div>
        <div>
          <h1 className="text-xl font-bold text-slate-800 tracking-tight flex items-center gap-2">
            SMRITI <span className="text-xs font-semibold px-2 py-0.5 rounded-full bg-sky-100 text-sky-700">SIH 2026</span>
          </h1>
          <p className="text-xs text-slate-500">Caregiver & Health-Worker Portal</p>
        </div>
      </div>

      <div className="flex items-center space-x-6">
        {/* Sync Status Indicator */}
        <div className="flex items-center space-x-2 px-3 py-1.5 rounded-lg bg-emerald-50 border border-emerald-200 text-emerald-700 text-xs font-medium">
          <Wifi className="w-3.5 h-3.5 text-emerald-600" />
          <span>Sync Status: <strong>{syncStatus.toUpperCase()}</strong> ({lastSyncTime})</span>
        </div>

        {/* Patient Badge */}
        {currentPatient && (
          <div className="flex items-center space-x-2 px-3 py-1.5 rounded-lg bg-slate-100 text-slate-700 text-xs">
            <UserIcon className="w-3.5 h-3.5 text-slate-500" />
            <span>Active Profile: <strong>{currentPatient.display_name}</strong></span>
          </div>
        )}

        <button
          onClick={onLogout}
          className="text-xs font-medium text-slate-600 hover:text-slate-900 px-3 py-1.5 rounded-md hover:bg-slate-100 transition-colors"
        >
          Sign Out
        </button>
      </div>
    </header>
  );
};

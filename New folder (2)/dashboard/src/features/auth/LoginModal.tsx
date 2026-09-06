import React, { useState } from 'react';
import { Heart, Lock, Mail, UserCheck } from 'lucide-react';

interface LoginModalProps {
  onLogin: (token: string, user: any) => void;
}

export const LoginModal: React.FC<LoginModalProps> = ({ onLogin }) => {
  const [email, setEmail] = useState('caregiver@smriti.ner');
  const [password, setPassword] = useState('caregiver123');
  const [role, setRole] = useState<'CAREGIVER' | 'HEALTHCARE_WORKER'>('CAREGIVER');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    // Real / local auth handshake simulation
    setTimeout(() => {
      onLogin('mock_jwt_token_auth_verified_2026', {
        id: 'usr_caregiver_001',
        email,
        full_name: role === 'CAREGIVER' ? 'Ananya Sharma (Caregiver)' : 'Dr. Bipin Barua (Community Worker)',
        role
      });
      setIsLoading(false);
    }, 600);
  };

  return (
    <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-md flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-3xl max-w-md w-full p-8 shadow-2xl border border-slate-100">
        <div className="text-center mb-6">
          <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-sky-600 to-indigo-600 flex items-center justify-center text-white mx-auto shadow-lg shadow-sky-500/25 mb-3">
            <Heart className="w-6 h-6 fill-current" />
          </div>
          <h2 className="text-2xl font-bold text-slate-800">SMRITI Portal Login</h2>
          <p className="text-xs text-slate-500 mt-1">Caregiver & Healthcare Worker Console</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="flex p-1 bg-slate-100 rounded-xl">
            <button
              type="button"
              onClick={() => setRole('CAREGIVER')}
              className={`flex-1 py-2 text-xs font-semibold rounded-lg transition-all ${
                role === 'CAREGIVER' ? 'bg-white text-sky-700 shadow-sm' : 'text-slate-500'
              }`}
            >
              Family Caregiver
            </button>
            <button
              type="button"
              onClick={() => setRole('HEALTHCARE_WORKER')}
              className={`flex-1 py-2 text-xs font-semibold rounded-lg transition-all ${
                role === 'HEALTHCARE_WORKER' ? 'bg-white text-sky-700 shadow-sm' : 'text-slate-500'
              }`}
            >
              Health Worker
            </button>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-600 mb-1">Email Address</label>
            <div className="relative">
              <Mail className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full pl-9 pr-3 py-2.5 text-sm border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-sky-500"
                required
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-600 mb-1">Password</label>
            <div className="relative">
              <Lock className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full pl-9 pr-3 py-2.5 text-sm border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-sky-500"
                required
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className="w-full py-3 bg-gradient-to-r from-sky-600 to-indigo-600 hover:from-sky-700 hover:to-indigo-700 text-white rounded-xl text-sm font-bold shadow-md shadow-sky-500/20 transition-all flex items-center justify-center space-x-2"
          >
            <UserCheck className="w-4 h-4" />
            <span>{isLoading ? 'Authenticating...' : 'Access Dashboard'}</span>
          </button>
        </form>

        <div className="mt-6 pt-4 border-t border-slate-100 text-center">
          <p className="text-[11px] text-slate-400">
            Patients access via one-tap elderly mode on mobile. No complex login required for elderly users.
          </p>
        </div>
      </div>
    </div>
  );
};

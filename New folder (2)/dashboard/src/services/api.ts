import axios from 'axios';
import { Patient, GameSession, LongitudinalSummary, Reminder, ActivityAlert } from '../types';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api/v1';

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const api = {
  // Auth
  login: async (email: string, password: string) => {
    const res = await apiClient.post('/auth/login', { email, password });
    return res.data;
  },

  // Patients
  getPatients: async (caregiverId: string): Promise<Patient[]> => {
    const res = await apiClient.get(`/patients?caregiver_id=${caregiverId}`);
    return res.data;
  },

  getPatient: async (patientId: string): Promise<Patient> => {
    const res = await apiClient.get(`/patients/${patientId}`);
    return res.data;
  },

  // Sessions & Trends
  getPatientSessions: async (patientId: string): Promise<GameSession[]> => {
    const res = await apiClient.get(`/patients/${patientId}/sessions`);
    return res.data;
  },

  getPatientTrends: async (patientId: string, windowDays: number = 7): Promise<LongitudinalSummary> => {
    const res = await apiClient.get(`/patients/${patientId}/trends?window_days=${windowDays}`);
    return res.data;
  },

  // Reminders
  getReminders: async (patientId: string): Promise<Reminder[]> => {
    const res = await apiClient.get(`/patients/${patientId}/reminders`);
    return res.data;
  },

  createReminder: async (patientId: string, data: Partial<Reminder>): Promise<Reminder> => {
    const res = await apiClient.post(`/patients/${patientId}/reminders`, data);
    return res.data;
  },

  // Alerts
  getAlerts: async (patientId: string): Promise<ActivityAlert[]> => {
    const res = await apiClient.get(`/patients/${patientId}/alerts`);
    return res.data;
  },

  acknowledgeAlert: async (alertId: string): Promise<ActivityAlert> => {
    const res = await apiClient.patch(`/alerts/${alertId}/acknowledge`);
    return res.data;
  }
};

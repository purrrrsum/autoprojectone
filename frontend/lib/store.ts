'use client';

import { create } from 'zustand';
import { 
  ActivityLevel, 
  KeywordCategory, 
  EmotionalState, 
  UserPreferences,
  SessionConfig 
} from '../types';

interface AppState {
  // 3-Layer Login System
  activityLevel: ActivityLevel | null;
  keywordCategory: KeywordCategory | null;
  customKeyword: string;
  emotionalState: EmotionalState | null;
  userPreferences: UserPreferences | null;
  
  // Current view state
  currentView: 'activity-selector' | 'keyword-selector' | 'emotion-selector' | 'chat' | 'loading' | 'error';
  
  // Chat state
  isConnected: boolean;
  sessionId: string | null;
  messages: any[];
  matchedUser: any | null;
  
  // UI state
  isLoading: boolean;
  error: string | null;
  
  // Actions
  setActivityLevel: (level: ActivityLevel) => void;
  setKeywordCategory: (category: KeywordCategory) => void;
  setCustomKeyword: (keyword: string) => void;
  setEmotionalState: (emotion: EmotionalState) => void;
  setUserPreferences: (preferences: UserPreferences) => void;
  setCurrentView: (view: AppState['currentView']) => void;
  
  // Chat actions
  connect: () => void;
  disconnect: () => void;
  joinChat: (preferences: UserPreferences) => void;
  leaveChat: () => void;
  sendMessage: (message: string) => void;
  
  // UI actions
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  
  // Session configuration
  getSessionConfig: () => SessionConfig[keyof SessionConfig] | null;
}

export const useStore = create<AppState>((set, get) => ({
  // Initial state
  activityLevel: null,
  keywordCategory: null,
  customKeyword: '',
  emotionalState: null,
  userPreferences: null,
  currentView: 'activity-selector',
  
  isConnected: false,
  sessionId: null,
  messages: [],
  matchedUser: null,
  
  isLoading: false,
  error: null,
  
  // Actions
  setActivityLevel: (level) => {
    set({ activityLevel: level });
    // Auto-advance to next step
    if (level) {
      set({ currentView: 'keyword-selector' });
    }
  },
  
  setKeywordCategory: (category) => {
    set({ keywordCategory: category });
    // Auto-advance to next step
    if (category) {
      set({ currentView: 'emotion-selector' });
    }
  },
  
  setCustomKeyword: (keyword) => {
    set({ customKeyword: keyword });
  },
  
  setEmotionalState: (emotion) => {
    set({ emotionalState: emotion });
    // Create user preferences and start chat
    const { activityLevel, keywordCategory, customKeyword } = get();
    if (activityLevel && keywordCategory) {
      const preferences: UserPreferences = {
        activityLevel,
        keywordCategory,
        customKeyword: keywordCategory === 'custom' ? customKeyword : undefined,
        emotionalState: emotion,
        gender: undefined // Optional gender selection
      };
      set({ userPreferences: preferences });
      get().joinChat(preferences);
    }
  },
  
  setUserPreferences: (preferences) => {
    set({ userPreferences: preferences });
  },
  
  setCurrentView: (view) => {
    set({ currentView: view });
  },
  
  // Chat actions
  connect: () => {
    set({ isConnected: true, isLoading: false });
  },
  
  disconnect: () => {
    set({ 
      isConnected: false, 
      sessionId: null, 
      messages: [], 
      matchedUser: null,
      currentView: 'activity-selector' // Reset to start
    });
  },
  
  joinChat: (preferences) => {
    set({ isLoading: true, currentView: 'loading' });
    
    // Simulate WebSocket connection and matching
    setTimeout(() => {
      set({ 
        isLoading: false, 
        currentView: 'chat',
        sessionId: `session-${Date.now()}`,
        matchedUser: { id: 'user-456', preferences }
      });
    }, 2000);
  },
  
  leaveChat: () => {
    set({ 
      sessionId: null, 
      messages: [], 
      matchedUser: null,
      currentView: 'activity-selector'
    });
  },
  
  sendMessage: (message) => {
    const { messages } = get();
    const newMessage = {
      id: Date.now(),
      content: message,
      sender: 'me',
      timestamp: new Date().toISOString()
    };
    set({ messages: [...messages, newMessage] });
  },
  
  setLoading: (loading) => {
    set({ isLoading: loading });
  },
  
  setError: (error) => {
    set({ error, isLoading: false });
  },
  
  // Get session configuration based on activity level
  getSessionConfig: () => {
    const { activityLevel } = get();
    if (!activityLevel) return null;
    
    const config: SessionConfig = {
      immediate: {
        responseTimeout: 30000,
        sessionTimeout: 3600000,
        maxMessagesPerMinute: 20,
        autoReconnect: true
      },
      medium: {
        responseTimeout: 600000,
        sessionTimeout: 7200000,
        maxMessagesPerMinute: 10,
        autoReconnect: true
      },
      long: {
        responseTimeout: 86400000,
        sessionTimeout: 86400000,
        maxMessagesPerMinute: 5,
        autoReconnect: false
      }
    };
    
    return config[activityLevel];
  }
})); 
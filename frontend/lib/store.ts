'use client';

import { create } from 'zustand';
import type { AppState, Interest, Message, ChatSession, MessageStatus } from '@/types';
import { encryptionService } from './encryption';
import { websocketService } from './websocket';

const useAppStore = create<AppState>((set, get) => ({
  chat: {
    currentSession: null,
    sessions: [],
    isConnected: false,
    isConnecting: false,
    error: null,
    selectedInterest: null,
    partnerTyping: false,
    partnerDisconnected: false
  },
  encryption: {
    keys: null,
    isInitialized: false,
  },
  ui: {
    isLoading: false,
    showSettings: false,
    theme: 'light',
  },
  user: {
    id: null,
    sessionId: null,
    interest: null
  },

  // Chat actions
  initializeChat: async () => {
    set({ ui: { ...get().ui, isLoading: true } });
    
    try {
      if (encryptionService.isSupported()) {
        const keys = await encryptionService.initialize();
        set({ encryption: { keys, isInitialized: true } });
      }
      await websocketService.connect();
      set({ 
        chat: { ...get().chat, isConnecting: false },
        ui: { ...get().ui, isLoading: false }
      });
    } catch (error) {
      console.error('Chat initialization failed:', error);
      set({ 
        chat: { ...get().chat, error: error instanceof Error ? error.message : 'Failed to initialize chat' },
        ui: { ...get().ui, isLoading: false }
      });
    }
  },

  joinChat: async (interest: Interest) => {
    try {
      set({ chat: { ...get().chat, selectedInterest: interest, isConnecting: true } });
      await websocketService.join(interest);
      set({ 
        chat: { ...get().chat, isConnecting: false },
        user: { ...get().user, interest }
      });
    } catch (error) {
      console.error('Join chat failed:', error);
      set({ 
        chat: { ...get().chat, error: error instanceof Error ? error.message : 'Failed to join chat', isConnecting: false }
      });
    }
  },

  sendMessage: async (content: string) => {
    const { currentSession } = get().chat;
    if (!currentSession) throw new Error('No active chat session');
    try {
      await websocketService.sendMessage(content, currentSession.id);
    } catch (error) {
      console.error('Send message failed:', error);
      throw error;
    }
  },

  leaveChat: () => {
    websocketService.leave();
    set({ 
      chat: { 
        ...get().chat, 
        currentSession: null,
        sessions: [],
        selectedInterest: null,
        partnerTyping: false,
        partnerDisconnected: false
      }
    });
  },

  // WebSocket actions
  setWebSocketConnected: (isConnected: boolean) => {
    set({ chat: { ...get().chat, isConnected } });
  },

  setSessionId: (sessionId: string) => {
    set({ user: { ...get().user, sessionId } });
  },

  setUserId: (userId: string) => {
    set({ user: { ...get().user, id: userId } });
  },

  setInterest: (interest: Interest) => {
    set({ user: { ...get().user, interest } });
  },

  createChatSession: (sessionId: string, interest: Interest) => {
    const newSession: ChatSession = {
      id: sessionId,
      interest,
      partnerId: '',
      messages: [],
      createdAt: Date.now(),
      lastActivity: Date.now(),
      isActive: true
    };
    set({ 
      chat: { 
        ...get().chat, 
        currentSession: newSession,
        sessions: [...get().chat.sessions, newSession]
      }
    });
  },

  addMessage: (message: Message) => {
    const { currentSession, sessions } = get().chat;
    if (!currentSession) return;

    const updatedSession = {
      ...currentSession,
      messages: [...currentSession.messages, message],
      lastActivity: Date.now()
    };

    const updatedSessions = sessions.map(session => 
      session.id === currentSession.id ? updatedSession : session
    );

    set({ 
      chat: { 
        ...get().chat, 
        currentSession: updatedSession,
        sessions: updatedSessions
      }
    });
  },

  updateMessageStatus: (messageId: string, status: MessageStatus) => {
    const { currentSession, sessions } = get().chat;
    if (!currentSession) return;

    const updateMessages = (messages: Message[]) =>
      messages.map(msg => 
        msg.id === messageId ? { ...msg, status } : msg
      );

    const updatedSession = {
      ...currentSession,
      messages: updateMessages(currentSession.messages)
    };

    const updatedSessions = sessions.map(session => 
      session.id === currentSession.id ? updatedSession : session
    );

    set({ 
      chat: { 
        ...get().chat, 
        currentSession: updatedSession,
        sessions: updatedSessions
      }
    });
  },

  setPartnerTyping: (isTyping: boolean) => {
    set({ chat: { ...get().chat, partnerTyping: isTyping } });
  },

  setPartnerDisconnected: () => {
    set({ chat: { ...get().chat, partnerDisconnected: true } });
  },

  // UI actions
  setLoading: (isLoading: boolean) => {
    set({ ui: { ...get().ui, isLoading } });
  },

  setError: (error: string | null) => {
    set({ chat: { ...get().chat, error } });
  },

  setShowSettings: (showSettings: boolean) => {
    set({ ui: { ...get().ui, showSettings } });
  },

  setTheme: (theme: 'light' | 'dark') => {
    set({ ui: { ...get().ui, theme } });
  },

  // Encryption actions
  initializeEncryption: async () => {
    try {
      if (!encryptionService.isSupported()) {
        throw new Error('Web Crypto API not supported');
      }
      const keys = await encryptionService.initialize();
      set({ encryption: { keys, isInitialized: true } });
    } catch (error) {
      console.error('Encryption initialization failed:', error);
      throw error;
    }
  },

  // Cleanup
  disconnect: () => {
    websocketService.disconnect();
    set({ 
      chat: {
        currentSession: null,
        sessions: [],
        isConnected: false,
        isConnecting: false,
        error: null,
        selectedInterest: null,
        partnerTyping: false,
        partnerDisconnected: false
      },
      encryption: {
        keys: null,
        isInitialized: false,
      },
      user: {
        id: null,
        sessionId: null,
        interest: null
      }
    });
  }
}));

export { useAppStore }; 
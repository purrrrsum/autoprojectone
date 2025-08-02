export type Interest = 'science' | 'tech' | 'politics' | 'personal';

export type MessageStatus = 'sending' | 'sent' | 'failed';

export interface Message {
  id: string;
  content: string;
  timestamp: number;
  isFromMe: boolean;
  status: MessageStatus;
}

export interface ChatSession {
  id: string;
  interest: Interest;
  partnerId: string;
  messages: Message[];
  createdAt: number;
  lastActivity: number;
  isActive: boolean;
}

export interface ChatState {
  currentSession: ChatSession | null;
  sessions: ChatSession[];
  isConnected: boolean;
  isConnecting: boolean;
  error: string | null;
  selectedInterest: Interest | null;
  partnerTyping: boolean;
  partnerDisconnected: boolean;
}

export interface WebSocketMessage {
  type: 'message' | 'join' | 'leave' | 'typing' | 'error' | 'match' | 'disconnect' | 'connected' | 'joined' | 'message_sent' | 'partner_disconnected';
  payload?: any;
  timestamp: number;
  sessionId?: string;
  userId?: string;
  interest?: Interest;
  chatSessionId?: string;
  messageId?: string;
  content?: string;
  iv?: string;
  tag?: string;
  isTyping?: boolean;
  error?: string;
}

export interface EncryptionKey {
  publicKey: string;
  privateKey: string;
  sharedSecret?: string;
}

export interface UserState {
  id: string | null;
  sessionId: string | null;
  interest: Interest | null;
}

export interface AppState {
  chat: ChatState;
  encryption: {
    keys: EncryptionKey | null;
    isInitialized: boolean;
  };
  ui: {
    isLoading: boolean;
    showSettings: boolean;
    theme: 'light' | 'dark';
  };
  user: UserState;

  // Chat actions
  initializeChat: () => Promise<void>;
  joinChat: (interest: Interest) => Promise<void>;
  sendMessage: (content: string) => Promise<void>;
  leaveChat: () => void;

  // WebSocket actions
  setWebSocketConnected: (isConnected: boolean) => void;
  setSessionId: (sessionId: string) => void;
  setUserId: (userId: string) => void;
  setInterest: (interest: Interest) => void;
  createChatSession: (sessionId: string, interest: Interest) => void;
  addMessage: (message: Message) => void;
  updateMessageStatus: (messageId: string, status: MessageStatus) => void;
  setPartnerTyping: (isTyping: boolean) => void;
  setPartnerDisconnected: () => void;

  // UI actions
  setLoading: (isLoading: boolean) => void;
  setError: (error: string | null) => void;
  setShowSettings: (showSettings: boolean) => void;
  setTheme: (theme: 'light' | 'dark') => void;

  // Encryption actions
  initializeEncryption: () => Promise<void>;

  // Cleanup
  disconnect: () => void;
}

 
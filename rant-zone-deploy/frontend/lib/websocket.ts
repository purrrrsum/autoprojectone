import { encryptionService } from './encryption';
import { useAppStore } from './store';

export interface WebSocketMessage {
  type: 'message' | 'join' | 'leave' | 'typing' | 'error' | 'match' | 'disconnect' | 'connected' | 'joined' | 'message_sent' | 'partner_disconnected';
  payload?: any;
  timestamp: number;
}

class WebSocketService {
  private ws: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectDelay = 1000;
  private heartbeatInterval: NodeJS.Timeout | null = null;
  private isConnecting = false;

  async connect(): Promise<void> {
    if (this.ws?.readyState === WebSocket.OPEN || this.isConnecting) {
      return;
    }

    this.isConnecting = true;

    try {
      const wsUrl = process.env.NEXT_PUBLIC_WEBSOCKET_URL || 'ws://localhost:3001';
      this.ws = new WebSocket(wsUrl);

      this.ws.onopen = () => {
        console.log('WebSocket connected');
        this.isConnecting = false;
        this.reconnectAttempts = 0;
        this.startHeartbeat();
        useAppStore.getState().setWebSocketConnected(true);
      };

      this.ws.onmessage = (event) => {
        this.handleMessage(event.data);
      };

      this.ws.onclose = (event) => {
        console.log('WebSocket disconnected:', event.code, event.reason);
        this.isConnecting = false;
        this.stopHeartbeat();
        useAppStore.getState().setWebSocketConnected(false);
        
        if (!event.wasClean && this.reconnectAttempts < this.maxReconnectAttempts) {
          this.scheduleReconnect();
        }
      };

      this.ws.onerror = (error) => {
        console.error('WebSocket error:', error);
        this.isConnecting = false;
      };

    } catch (error) {
      console.error('WebSocket connection failed:', error);
      this.isConnecting = false;
      throw error;
    }
  }

  private handleMessage(data: string) {
    try {
      const message: WebSocketMessage = JSON.parse(data);
      console.log('Received message:', message.type);

      switch (message.type) {
        case 'connected':
          this.handleConnected(message);
          break;
        case 'joined':
          this.handleJoined(message);
          break;
        case 'matched':
          this.handleMatched(message);
          break;
        case 'message':
          this.handleChatMessage(message);
          break;
        case 'message_sent':
          this.handleMessageSent(message);
          break;
        case 'typing':
          this.handleTyping(message);
          break;
        case 'partner_disconnected':
          this.handlePartnerDisconnected(message);
          break;
        case 'error':
          this.handleError(message);
          break;
        default:
          console.warn('Unknown message type:', message.type);
      }
    } catch (error) {
      console.error('Message parsing error:', error);
    }
  }

  private handleConnected(message: WebSocketMessage) {
    useAppStore.getState().setSessionId(message.sessionId || '');
  }

  private handleJoined(message: WebSocketMessage) {
    useAppStore.getState().setUserId(message.userId || '');
  }

  private handleMatched(message: WebSocketMessage) {
    if (message.chatSessionId && message.interest) {
      useAppStore.getState().createChatSession(message.chatSessionId, message.interest);
    }
  }

  private async handleChatMessage(message: WebSocketMessage) {
    try {
      if (message.content && message.iv && message.tag) {
        const encryptedMessage = {
          encryptedData: message.content,
          iv: message.iv,
          tag: message.tag
        };
        
        const decryptedContent = await encryptionService.decrypt(encryptedMessage);
        
        const chatMessage = {
          id: message.messageId || `msg-${Date.now()}`,
          content: decryptedContent,
          timestamp: message.timestamp,
          isFromMe: false,
          status: 'sent' as const
        };
        
        useAppStore.getState().addMessage(chatMessage);
      }
    } catch (error) {
      console.error('Failed to decrypt message:', error);
    }
  }

  private handleMessageSent(message: WebSocketMessage) {
    if (message.messageId) {
      useAppStore.getState().updateMessageStatus(message.messageId, 'sent');
    }
  }

  private handleTyping(message: WebSocketMessage) {
    useAppStore.getState().setPartnerTyping(message.isTyping || false);
  }

  private handlePartnerDisconnected(message: WebSocketMessage) {
    useAppStore.getState().setPartnerDisconnected();
  }

  private handleError(message: WebSocketMessage) {
    console.error('WebSocket error:', message.error);
    useAppStore.getState().setError(message.error || 'WebSocket error');
  }

  async join(interest: string): Promise<void> {
    if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
      throw new Error('WebSocket not connected');
    }

    const message = {
      type: 'join',
      payload: { interest },
      timestamp: Date.now()
    };

    this.ws.send(JSON.stringify(message));
  }

  async sendMessage(content: string, chatSessionId: string): Promise<void> {
    if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
      throw new Error('WebSocket not connected');
    }

    try {
      const encryptedMessage = await encryptionService.encrypt(content);
      
      const message = {
        type: 'message',
        payload: {
          content: encryptedMessage.encryptedData,
          iv: encryptedMessage.iv,
          tag: encryptedMessage.tag,
          chatSessionId
        },
        timestamp: Date.now()
      };

      this.ws.send(JSON.stringify(message));
    } catch (error) {
      console.error('Failed to encrypt message:', error);
      throw error;
    }
  }

  sendTyping(isTyping: boolean, chatSessionId: string): void {
    if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
      return;
    }

    const message = {
      type: 'typing',
      payload: { isTyping, chatSessionId },
      timestamp: Date.now()
    };

    this.ws.send(JSON.stringify(message));
  }

  leave(): void {
    if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
      return;
    }

    const message = {
      type: 'leave',
      payload: {},
      timestamp: Date.now()
    };

    this.ws.send(JSON.stringify(message));
  }

  disconnect(): void {
    this.stopHeartbeat();
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }

  private startHeartbeat(): void {
    this.heartbeatInterval = setInterval(() => {
      if (this.ws && this.ws.readyState === WebSocket.OPEN) {
        this.ws.send(JSON.stringify({
          type: 'ping',
          timestamp: Date.now()
        }));
      }
    }, 30000);
  }

  private stopHeartbeat(): void {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
      this.heartbeatInterval = null;
    }
  }

  private scheduleReconnect(): void {
    setTimeout(() => {
      this.reconnectAttempts++;
      this.connect();
    }, this.reconnectDelay * this.reconnectAttempts);
  }

  isConnected(): boolean {
    return this.ws?.readyState === WebSocket.OPEN;
  }

  getReadyState(): number {
    return this.ws?.readyState || WebSocket.CLOSED;
  }
}

export const websocketService = new WebSocketService(); 
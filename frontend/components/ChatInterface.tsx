'use client';

import { useState, useEffect, useRef } from 'react';
import { useAppStore } from '@/lib/store';
import type { Message } from '@/types';

export default function ChatInterface() {
  const {
    chat,
    sendMessage,
    leaveChat,
    setPartnerTyping,
    addMessage,
    updateMessageStatus
  } = useAppStore();

  const [inputValue, setInputValue] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const typingTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  const currentSession = chat.currentSession;

  useEffect(() => {
    scrollToBottom();
  }, [currentSession?.messages]);

  useEffect(() => {
    return () => {
      if (typingTimeoutRef.current) {
        clearTimeout(typingTimeoutRef.current);
      }
    };
  }, []);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setInputValue(value);

    if (!isTyping) {
      setIsTyping(true);
      if (currentSession) {
        setPartnerTyping(true);
      }
    }

    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }
    typingTimeoutRef.current = setTimeout(() => {
      setIsTyping(false);
      setPartnerTyping(false);
    }, 2000);
  };

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!inputValue.trim() || !currentSession) return;

    const messageContent = inputValue.trim();
    setInputValue('');

    setIsTyping(false);
    setPartnerTyping(false);
    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }

    try {
      const optimisticMessage: Message = {
        id: `temp-${Date.now()}`,
        content: messageContent,
        timestamp: Date.now(),
        isFromMe: true,
        status: 'sending'
      };

      addMessage(optimisticMessage);
      await sendMessage(messageContent);
      updateMessageStatus(optimisticMessage.id, 'sent');

    } catch (error) {
      console.error('Failed to send message:', error);
      const failedMessage = currentSession.messages.find(m => m.content === messageContent && m.isFromMe);
      if (failedMessage) {
        updateMessageStatus(failedMessage.id, 'failed');
      }
    }
  };

  const handleLeaveChat = () => {
    leaveChat();
  };

  if (!currentSession) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <p className="text-gray-600">No active chat session</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <div className="bg-white border-b border-gray-200 p-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-xl font-semibold text-gray-900">Rant.Zone</h1>
            <p className="text-sm text-gray-600">
              {currentSession.interest} • Anonymous chat
            </p>
          </div>
          <button
            onClick={handleLeaveChat}
            className="px-4 py-2 text-sm font-medium text-red-600 hover:text-red-700 hover:bg-red-50 rounded"
          >
            Leave Chat
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-4">
        <div className="max-w-2xl mx-auto space-y-4">
          {currentSession.messages.length === 0 ? (
            <div className="text-center py-8">
              <p className="text-gray-500">Start the conversation!</p>
            </div>
          ) : (
            currentSession.messages.map((message) => (
              <div
                key={message.id}
                className={`flex ${message.isFromMe ? 'justify-end' : 'justify-start'}`}
              >
                <div
                  className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${
                    message.isFromMe
                      ? 'bg-primary-500 text-white'
                      : 'bg-white border border-gray-200 text-gray-900'
                  }`}
                >
                  <p className="text-sm">{message.content}</p>
                  <div className={`text-xs mt-1 ${
                    message.isFromMe ? 'text-blue-100' : 'text-gray-500'
                  }`}>
                    {new Date(message.timestamp).toLocaleTimeString([], {
                      hour: '2-digit',
                      minute: '2-digit'
                    })}
                    {message.status === 'sending' && ' • Sending...'}
                    {message.status === 'failed' && ' • Failed'}
                  </div>
                </div>
              </div>
            ))
          )}
          
          {chat.partnerTyping && (
            <div className="flex justify-start">
              <div className="bg-white border border-gray-200 rounded-lg px-4 py-2">
                <div className="flex space-x-1">
                  <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                  <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                  <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                </div>
              </div>
            </div>
          )}

          {chat.partnerDisconnected && (
            <div className="text-center py-4">
              <p className="text-sm text-gray-500 bg-gray-100 rounded-lg px-4 py-2 inline-block">
                Partner has disconnected
              </p>
            </div>
          )}

          <div ref={messagesEndRef} />
        </div>
      </div>

      <div className="bg-white border-t border-gray-200 p-4">
        <div className="max-w-2xl mx-auto">
          <form onSubmit={handleSendMessage} className="flex space-x-4">
            <input
              type="text"
              value={inputValue}
              onChange={handleInputChange}
              placeholder="Type your message..."
              className="flex-1 px-4 py-2 border border-gray-300 rounded focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              maxLength={500}
              disabled={chat.partnerDisconnected}
            />
            <button
              type="submit"
              disabled={!inputValue.trim() || chat.partnerDisconnected}
              className="px-6 py-2 bg-primary-500 text-white rounded hover:bg-primary-600 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Send
            </button>
          </form>
          <div className="mt-2 text-xs text-gray-500 text-center">
            Messages are encrypted and auto-delete after 30 days
          </div>
        </div>
      </div>
    </div>
  );
} 
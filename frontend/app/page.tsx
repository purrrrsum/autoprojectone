'use client';

import { useEffect } from 'react';
import { useAppStore } from '@/lib/store';
import InterestSelector from '@/components/InterestSelector';
import ChatInterface from '@/components/ChatInterface';
import LoadingSpinner from '@/components/LoadingSpinner';
import ErrorMessage from '@/components/ErrorMessage';

export default function HomePage() {
  const {
    chat,
    ui,
    initializeChat,
    setError,
  } = useAppStore();

  useEffect(() => {
    initializeChat().catch((error) => {
      setError(error instanceof Error ? error.message : 'Failed to initialize chat');
    });
  }, [initializeChat, setError]);

  if (ui.isLoading || chat.isConnecting) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <LoadingSpinner />
          <p className="mt-4 text-gray-600">
            {chat.isConnecting ? 'Connecting to chat...' : 'Initializing...'}
          </p>
        </div>
      </div>
    );
  }

  if (chat.error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <ErrorMessage 
          message={chat.error}
          onRetry={() => initializeChat()}
        />
      </div>
    );
  }

  if (!chat.currentSession) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="w-full max-w-md">
          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-2">
              Rant.Zone
            </h1>
            <p className="text-gray-600">
              Anonymous ephemeral chat. Choose your interest to start ranting.
            </p>
          </div>
          
          <InterestSelector />
          
          <div className="mt-8 text-center text-sm text-gray-500">
            <p>Messages are encrypted and auto-delete after 30 days</p>
            <p>No images, links, or user profiles allowed</p>
          </div>
        </div>
      </div>
    );
  }

  return <ChatInterface />;
} 
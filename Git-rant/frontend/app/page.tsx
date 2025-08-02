'use client';

import { useEffect } from 'react';
import { useAppStore } from '@/lib/store';
import InterestSelector from '@/components/InterestSelector';
import GenderSelector from '@/components/GenderSelector';
import ChatInterface from '@/components/ChatInterface';
import LoadingSpinner from '@/components/LoadingSpinner';
import ErrorMessage from '@/components/ErrorMessage';

export default function Home() {
  const { 
    chat, 
    ui, 
    user,
    initializeChat, 
    setError,
    setShowGenderSelector
  } = useAppStore();

  useEffect(() => {
    initializeChat().catch((error) => {
      setError('Failed to initialize chat');
    });
  }, [initializeChat, setError]);

  // Show gender selector if user hasn't selected gender yet
  useEffect(() => {
    if (!user.gender && !ui.showGenderSelector && !ui.isLoading && !chat.error) {
      setShowGenderSelector(true);
    }
  }, [user.gender, ui.showGenderSelector, ui.isLoading, chat.error, setShowGenderSelector]);

  if (ui.isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <LoadingSpinner />
      </div>
    );
  }

  if (chat.error) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4">
        <ErrorMessage 
          message={chat.error} 
          onRetry={() => initializeChat()} 
        />
      </div>
    );
  }

  if (ui.showGenderSelector) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4 bg-gray-50">
        <GenderSelector />
      </div>
    );
  }

  if (!chat.selectedInterest) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4 bg-gray-50">
        <div className="max-w-md w-full">
          <h1 className="text-2xl font-bold text-center mb-8">Choose Interest</h1>
          <InterestSelector />
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen">
      <ChatInterface />
    </div>
  );
} 
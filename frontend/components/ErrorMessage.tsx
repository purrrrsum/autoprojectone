import React from 'react';

interface ErrorMessageProps {
  message: string;
  onRetry?: () => void;
}

export default function ErrorMessage({ message, onRetry }: ErrorMessageProps) {
  return (
    <div className="text-center max-w-md mx-auto p-6">
      <div className="theme-card rounded-lg p-6 border-2 border-red-200">
        <div className="text-red-500 text-4xl mb-4">⚠️</div>
        <p className="theme-text text-lg font-medium mb-4">{message}</p>
        {onRetry && (
          <button
            onClick={onRetry}
            className="px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
          >
            Try Again
          </button>
        )}
      </div>
    </div>
  );
} 
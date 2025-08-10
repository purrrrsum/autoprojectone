import React from 'react';

export default function LoadingSpinner() {
  return (
    <div className="flex flex-col items-center justify-center space-y-4">
      <div className="animate-spin rounded-full h-12 w-12 border-4 border-blue-500 border-t-transparent"></div>
      <p className="theme-text text-lg font-medium">Loading...</p>
    </div>
  );
} 
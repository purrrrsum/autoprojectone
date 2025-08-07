'use client';

import { useStore } from '../lib/store';
import ActivityLevelSelector from '../components/ActivityLevelSelector';
import KeywordCategorySelector from '../components/KeywordCategorySelector';
import EmotionalStateSelector from '../components/EmotionalStateSelector';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';

export default function Home() {
  const {
    currentView,
    activityLevel,
    keywordCategory,
    customKeyword,
    emotionalState,
    isLoading,
    error,
    setActivityLevel,
    setKeywordCategory,
    setCustomKeyword,
    setEmotionalState
  } = useStore();

  if (error) {
    return <ErrorMessage message={error} />;
  }

  if (isLoading) {
    return <LoadingSpinner />;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-purple-50">
      <div className="container mx-auto px-4 py-8">
        {/* Header */}
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">Rant.Zone</h1>
          <p className="text-lg text-gray-600">Anonymous ephemeral chat with perfect matches</p>
        </div>

        {/* Progress Indicator */}
        <div className="max-w-md mx-auto mb-8">
          <div className="flex items-center justify-between">
            <div className={`flex items-center ${currentView === 'activity-selector' ? 'text-blue-600' : 'text-gray-400'}`}>
              <div className={`w-8 h-8 rounded-full flex items-center justify-center ${currentView === 'activity-selector' ? 'bg-blue-600 text-white' : 'bg-gray-200'}`}>
                1
              </div>
              <span className="ml-2 text-sm font-medium">Activity</span>
            </div>
            <div className={`flex-1 h-1 mx-4 ${currentView !== 'activity-selector' ? 'bg-blue-600' : 'bg-gray-200'}`}></div>
            <div className={`flex items-center ${currentView === 'keyword-selector' ? 'text-blue-600' : 'text-gray-400'}`}>
              <div className={`w-8 h-8 rounded-full flex items-center justify-center ${currentView === 'keyword-selector' ? 'bg-blue-600 text-white' : currentView !== 'activity-selector' ? 'bg-blue-600 text-white' : 'bg-gray-200'}`}>
                2
              </div>
              <span className="ml-2 text-sm font-medium">Topic</span>
            </div>
            <div className={`flex-1 h-1 mx-4 ${currentView === 'emotion-selector' || currentView === 'chat' ? 'bg-blue-600' : 'bg-gray-200'}`}></div>
            <div className={`flex items-center ${currentView === 'emotion-selector' ? 'text-blue-600' : 'text-gray-400'}`}>
              <div className={`w-8 h-8 rounded-full flex items-center justify-center ${currentView === 'emotion-selector' ? 'bg-blue-600 text-white' : currentView === 'chat' ? 'bg-blue-600 text-white' : 'bg-gray-200'}`}>
                3
              </div>
              <span className="ml-2 text-sm font-medium">Mood</span>
            </div>
          </div>
        </div>

        {/* Content based on current view */}
        {currentView === 'activity-selector' && (
          <ActivityLevelSelector
            selectedLevel={activityLevel}
            onSelect={setActivityLevel}
          />
        )}

        {currentView === 'keyword-selector' && (
          <KeywordCategorySelector
            selectedCategory={keywordCategory}
            customKeyword={customKeyword}
            onSelectCategory={setKeywordCategory}
            onCustomKeywordChange={setCustomKeyword}
          />
        )}

        {currentView === 'emotion-selector' && (
          <EmotionalStateSelector
            selectedEmotion={emotionalState}
            onSelectEmotion={setEmotionalState}
            onSkip={() => setEmotionalState('none')}
          />
        )}

        {currentView === 'chat' && (
          <div className="max-w-4xl mx-auto text-center">
            <div className="bg-white rounded-lg shadow-lg p-8">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Chat Interface</h2>
              <p className="text-gray-600 mb-6">Your chat interface will be implemented here</p>
              <button
                onClick={() => useStore.getState().leaveChat()}
                className="px-6 py-3 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors"
              >
                Leave Chat
              </button>
            </div>
          </div>
        )}

        {/* Navigation buttons */}
        {currentView !== 'activity-selector' && currentView !== 'chat' && (
          <div className="flex justify-center mt-8 space-x-4">
            <button
              onClick={() => {
                if (currentView === 'keyword-selector') {
                  useStore.getState().setCurrentView('activity-selector');
                } else if (currentView === 'emotion-selector') {
                  useStore.getState().setCurrentView('keyword-selector');
                }
              }}
              className="px-6 py-3 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
            >
              Back
            </button>
          </div>
        )}
      </div>
    </div>
  );
} 
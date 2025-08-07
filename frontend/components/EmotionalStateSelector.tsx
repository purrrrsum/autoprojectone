import React from 'react';
import { EmotionalState } from '../types';

interface EmotionalStateSelectorProps {
  selectedEmotion: EmotionalState | null;
  onSelectEmotion: (emotion: EmotionalState) => void;
  onSkip: () => void;
}

const emotionalStates = [
  {
    id: 'angry' as EmotionalState,
    title: 'Angry',
    description: 'Frustrated, irritated, mad',
    icon: '😠',
    color: 'bg-red-100 border-red-300'
  },
  {
    id: 'sad' as EmotionalState,
    title: 'Sad',
    description: 'Depressed, lonely, down',
    icon: '😢',
    color: 'bg-blue-100 border-blue-300'
  },
  {
    id: 'happy' as EmotionalState,
    title: 'Happy',
    description: 'Joyful, excited, positive',
    icon: '😊',
    color: 'bg-yellow-100 border-yellow-300'
  },
  {
    id: 'frustrated' as EmotionalState,
    title: 'Frustrated',
    description: 'Annoyed, stressed, overwhelmed',
    icon: '😤',
    color: 'bg-orange-100 border-orange-300'
  },
  {
    id: 'excited' as EmotionalState,
    title: 'Excited',
    description: 'Energetic, enthusiastic, pumped',
    icon: '🤩',
    color: 'bg-pink-100 border-pink-300'
  },
  {
    id: 'anxious' as EmotionalState,
    title: 'Anxious',
    description: 'Worried, nervous, tense',
    icon: '😰',
    color: 'bg-purple-100 border-purple-300'
  },
  {
    id: 'calm' as EmotionalState,
    title: 'Calm',
    description: 'Peaceful, relaxed, serene',
    icon: '😌',
    color: 'bg-green-100 border-green-300'
  },
  {
    id: 'confused' as EmotionalState,
    title: 'Confused',
    description: 'Lost, uncertain, puzzled',
    icon: '😵',
    color: 'bg-gray-100 border-gray-300'
  },
  {
    id: 'grateful' as EmotionalState,
    title: 'Grateful',
    description: 'Thankful, appreciative, blessed',
    icon: '🙏',
    color: 'bg-teal-100 border-teal-300'
  },
  {
    id: 'hopeful' as EmotionalState,
    title: 'Hopeful',
    description: 'Optimistic, positive, looking forward',
    icon: '✨',
    color: 'bg-indigo-100 border-indigo-300'
  },
  {
    id: 'none' as EmotionalState,
    title: 'Skip This',
    description: 'I prefer not to share my mood',
    icon: '🤐',
    color: 'bg-gray-50 border-gray-200'
  }
];

export default function EmotionalStateSelector({
  selectedEmotion,
  onSelectEmotion,
  onSkip
}: EmotionalStateSelectorProps) {
  return (
    <div className="max-w-6xl mx-auto p-6">
      <div className="text-center mb-8">
        <h2 className="text-3xl font-bold text-gray-900 mb-4">How Are You Feeling?</h2>
        <p className="text-lg text-gray-600">This helps us match you with someone who understands your mood</p>
        <p className="text-sm text-gray-500 mt-2">(Optional - you can skip this step)</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 mb-8">
        {emotionalStates.map((emotion) => (
          <div
            key={emotion.id}
            onClick={() => onSelectEmotion(emotion.id)}
            className={`
              relative p-4 rounded-lg border-2 cursor-pointer transition-all duration-200
              ${selectedEmotion === emotion.id
                ? 'border-blue-500 bg-blue-50 shadow-lg scale-105'
                : `${emotion.color} hover:shadow-md`
              }
            `}
          >
            {selectedEmotion === emotion.id && (
              <div className="absolute -top-2 -right-2 w-6 h-6 bg-blue-500 rounded-full flex items-center justify-center">
                <span className="text-white text-sm">✓</span>
              </div>
            )}

            <div className="text-center">
              <div className="text-3xl mb-2">{emotion.icon}</div>
              <h3 className="font-semibold text-gray-900 mb-1">{emotion.title}</h3>
              <p className="text-sm text-gray-600">{emotion.description}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="flex justify-center space-x-4">
        <button
          onClick={onSkip}
          className="px-6 py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
        >
          Skip This Step
        </button>
        
        {selectedEmotion && selectedEmotion !== 'none' && (
          <div className="inline-flex items-center px-4 py-2 bg-blue-100 text-blue-800 rounded-full">
            <span className="mr-2">Feeling:</span>
            <span className="font-semibold">
              {emotionalStates.find(e => e.id === selectedEmotion)?.title}
            </span>
          </div>
        )}
      </div>

      <div className="mt-8 text-center text-sm text-gray-500">
        <p>💡 <strong>Mood matching:</strong> We'll try to connect you with someone in a similar emotional state for better understanding.</p>
      </div>
    </div>
  );
} 
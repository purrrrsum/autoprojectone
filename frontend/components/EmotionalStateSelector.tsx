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
    icon: '😠'
  },
  {
    id: 'sad' as EmotionalState,
    title: 'Sad',
    description: 'Depressed, lonely, down',
    icon: '😢'
  },
  {
    id: 'happy' as EmotionalState,
    title: 'Happy',
    description: 'Joyful, excited, positive',
    icon: '😊'
  },
  {
    id: 'frustrated' as EmotionalState,
    title: 'Frustrated',
    description: 'Annoyed, stressed, overwhelmed',
    icon: '😤'
  },
  {
    id: 'excited' as EmotionalState,
    title: 'Excited',
    description: 'Energetic, enthusiastic, pumped',
    icon: '🤩'
  },
  {
    id: 'anxious' as EmotionalState,
    title: 'Anxious',
    description: 'Worried, nervous, tense',
    icon: '😰'
  },
  {
    id: 'calm' as EmotionalState,
    title: 'Calm',
    description: 'Peaceful, relaxed, serene',
    icon: '😌'
  },
  {
    id: 'confused' as EmotionalState,
    title: 'Confused',
    description: 'Lost, uncertain, puzzled',
    icon: '😵'
  },
  {
    id: 'grateful' as EmotionalState,
    title: 'Grateful',
    description: 'Thankful, appreciative, blessed',
    icon: '🙏'
  },
  {
    id: 'hopeful' as EmotionalState,
    title: 'Hopeful',
    description: 'Optimistic, positive, looking forward',
    icon: '✨'
  },
  {
    id: 'none' as EmotionalState,
    title: 'Skip This',
    description: 'I prefer not to share my mood',
    icon: '🤐'
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
        <h2 className="text-3xl font-bold theme-text mb-4">How Are You Feeling?</h2>
        <p className="text-lg theme-text-secondary">This helps us match you with someone who understands your mood</p>
        <p className="text-sm theme-text-tertiary mt-2">(Optional - you can skip this step)</p>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        {emotionalStates.map((emotion) => (
          <div
            key={emotion.id}
            onClick={() => onSelectEmotion(emotion.id)}
            className={`
              p-4 rounded-lg border-2 cursor-pointer transition-all duration-200 theme-card
              ${selectedEmotion === emotion.id
                ? 'border-blue-500 shadow-lg scale-105'
                : 'hover:border-blue-300 hover:shadow-md'
              }
            `}
          >
            <div className="text-center">
              <div className="text-3xl mb-2">{emotion.icon}</div>
              <h3 className="font-semibold theme-text text-sm">{emotion.title}</h3>
              <p className="theme-text-secondary text-xs mt-1">{emotion.description}</p>
            </div>
          </div>
        ))}
      </div>

      {selectedEmotion && (
        <div className="mt-8 text-center">
          <div className="inline-flex items-center px-4 py-2 theme-card border-2 border-pink-200 rounded-full">
            <span className="mr-2 theme-text-secondary">Selected:</span>
            <span className="font-semibold theme-text">
              {emotionalStates.find(e => e.id === selectedEmotion)?.title}
            </span>
          </div>
        </div>
      )}

      <div className="mt-8 text-center">
        <button
          onClick={onSkip}
          className="px-6 py-3 theme-card border-2 theme-text hover:border-blue-500 hover:text-blue-500 transition-colors rounded-lg"
        >
          Skip This Step
        </button>
      </div>
    </div>
  );
} 

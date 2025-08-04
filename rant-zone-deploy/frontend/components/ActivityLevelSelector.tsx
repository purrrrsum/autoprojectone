import React from 'react';
import { ActivityLevel } from '../types';

interface ActivityLevelSelectorProps {
  selectedLevel: ActivityLevel | null;
  onSelect: (level: ActivityLevel) => void;
}

const activityLevels = [
  {
    id: 'immediate' as ActivityLevel,
    title: 'Immediate Rant',
    description: 'Get instant responses! Perfect for quick venting and fast-paced conversations.',
    icon: '⚡',
    features: ['30-second response time', 'High activity chat', 'Auto-reconnect', '1-hour sessions']
  },
  {
    id: 'medium' as ActivityLevel,
    title: 'Medium Rant',
    description: 'Balanced pace with 5-10 minute response times. Great for thoughtful discussions.',
    icon: '⏱️',
    features: ['5-10 min response time', 'Moderate activity', 'Auto-reconnect', '2-hour sessions']
  },
  {
    id: 'long' as ActivityLevel,
    title: 'Long Rant',
    description: 'Deep conversations that last all day. Perfect for ongoing discussions and support.',
    icon: '🌙',
    features: ['24-hour response time', 'Low activity', 'Persistent sessions', 'Day-long conversations']
  }
];

export default function ActivityLevelSelector({ selectedLevel, onSelect }: ActivityLevelSelectorProps) {
  return (
    <div className="max-w-4xl mx-auto p-6">
      <div className="text-center mb-8">
        <h2 className="text-3xl font-bold text-gray-900 mb-4">Choose Your Rant Style</h2>
        <p className="text-lg text-gray-600">How active do you want to be today?</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {activityLevels.map((level) => (
          <div
            key={level.id}
            onClick={() => onSelect(level.id)}
            className={`
              relative p-6 rounded-xl border-2 cursor-pointer transition-all duration-200
              ${selectedLevel === level.id
                ? 'border-blue-500 bg-blue-50 shadow-lg scale-105'
                : 'border-gray-200 bg-white hover:border-gray-300 hover:shadow-md'
              }
            `}
          >
            {selectedLevel === level.id && (
              <div className="absolute -top-2 -right-2 w-6 h-6 bg-blue-500 rounded-full flex items-center justify-center">
                <span className="text-white text-sm">✓</span>
              </div>
            )}

            <div className="text-center">
              <div className="text-4xl mb-4">{level.icon}</div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">{level.title}</h3>
              <p className="text-gray-600 mb-4 text-sm">{level.description}</p>
              
              <div className="space-y-2">
                {level.features.map((feature, index) => (
                  <div key={index} className="flex items-center text-sm text-gray-700">
                    <span className="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
                    {feature}
                  </div>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>

      {selectedLevel && (
        <div className="mt-8 text-center">
          <div className="inline-flex items-center px-4 py-2 bg-blue-100 text-blue-800 rounded-full">
            <span className="mr-2">Selected:</span>
            <span className="font-semibold">
              {activityLevels.find(l => l.id === selectedLevel)?.title}
            </span>
          </div>
        </div>
      )}
    </div>
  );
} 
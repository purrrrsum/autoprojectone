import React, { useState } from 'react';
import { KeywordCategory } from '../types';

interface KeywordCategorySelectorProps {
  selectedCategory: KeywordCategory | null;
  customKeyword: string;
  onSelectCategory: (category: KeywordCategory) => void;
  onCustomKeywordChange: (keyword: string) => void;
}

const keywordCategories = [
  {
    id: 'personal-feelings' as KeywordCategory,
    title: 'Personal Feelings',
    description: 'Deep emotions, life struggles, personal growth',
    icon: '💭',
    color: 'bg-purple-100 border-purple-300'
  },
  {
    id: 'tech-rant' as KeywordCategory,
    title: 'Tech Rant',
    description: 'Software bugs, hardware issues, digital frustrations',
    icon: '💻',
    color: 'bg-blue-100 border-blue-300'
  },
  {
    id: 'office-rant' as KeywordCategory,
    title: 'Office Rant',
    description: 'Work stress, colleagues, meetings, deadlines',
    icon: '🏢',
    color: 'bg-gray-100 border-gray-300'
  },
  {
    id: 'social-rant' as KeywordCategory,
    title: 'Social Rant',
    description: 'Social media, relationships, society issues',
    icon: '👥',
    color: 'bg-green-100 border-green-300'
  },
  {
    id: 'relationship-rant' as KeywordCategory,
    title: 'Relationship Rant',
    description: 'Dating, family, friendships, love life',
    icon: '❤️',
    color: 'bg-pink-100 border-pink-300'
  },
  {
    id: 'health-rant' as KeywordCategory,
    title: 'Health Rant',
    description: 'Medical issues, fitness, wellness struggles',
    icon: '🏥',
    color: 'bg-red-100 border-red-300'
  },
  {
    id: 'money-rant' as KeywordCategory,
    title: 'Money Rant',
    description: 'Financial stress, bills, investments, economy',
    icon: '💰',
    color: 'bg-yellow-100 border-yellow-300'
  },
  {
    id: 'education-rant' as KeywordCategory,
    title: 'Education Rant',
    description: 'School, college, learning, academic stress',
    icon: '📚',
    color: 'bg-indigo-100 border-indigo-300'
  },
  {
    id: 'politics-rant' as KeywordCategory,
    title: 'Politics Rant',
    description: 'Political views, current events, government',
    icon: '🗳️',
    color: 'bg-orange-100 border-orange-300'
  },
  {
    id: 'entertainment-rant' as KeywordCategory,
    title: 'Entertainment Rant',
    description: 'Movies, music, games, pop culture',
    icon: '🎬',
    color: 'bg-teal-100 border-teal-300'
  },
  {
    id: 'custom' as KeywordCategory,
    title: 'Custom Topic',
    description: 'Create your own rant category',
    icon: '✨',
    color: 'bg-gradient-to-r from-purple-100 to-pink-100 border-purple-300'
  }
];

export default function KeywordCategorySelector({
  selectedCategory,
  customKeyword,
  onSelectCategory,
  onCustomKeywordChange
}: KeywordCategorySelectorProps) {
  const [showCustomInput, setShowCustomInput] = useState(false);

  const handleCategorySelect = (category: KeywordCategory) => {
    onSelectCategory(category);
    if (category === 'custom') {
      setShowCustomInput(true);
    } else {
      setShowCustomInput(false);
      onCustomKeywordChange('');
    }
  };

  return (
    <div className="max-w-6xl mx-auto p-6">
      <div className="text-center mb-8">
        <h2 className="text-3xl font-bold text-gray-900 mb-4">What's Your Rant About?</h2>
        <p className="text-lg text-gray-600">Choose a category or create your own</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
        {keywordCategories.map((category) => (
          <div
            key={category.id}
            onClick={() => handleCategorySelect(category.id)}
            className={`
              relative p-4 rounded-lg border-2 cursor-pointer transition-all duration-200
              ${selectedCategory === category.id
                ? 'border-blue-500 bg-blue-50 shadow-lg scale-105'
                : `${category.color} hover:shadow-md`
              }
            `}
          >
            {selectedCategory === category.id && (
              <div className="absolute -top-2 -right-2 w-6 h-6 bg-blue-500 rounded-full flex items-center justify-center">
                <span className="text-white text-sm">✓</span>
              </div>
            )}

            <div className="flex items-center space-x-3">
              <div className="text-2xl">{category.icon}</div>
              <div>
                <h3 className="font-semibold text-gray-900">{category.title}</h3>
                <p className="text-sm text-gray-600">{category.description}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      {showCustomInput && (
        <div className="max-w-md mx-auto">
          <div className="bg-white p-6 rounded-lg border-2 border-blue-300 shadow-lg">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Create Custom Category</h3>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Your Rant Topic
                </label>
                <input
                  type="text"
                  value={customKeyword}
                  onChange={(e) => onCustomKeywordChange(e.target.value)}
                  placeholder="e.g., pet peeves, travel frustrations, cooking disasters..."
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>
              <div className="text-sm text-gray-600">
                <p>💡 <strong>Pro tip:</strong> If 10+ people use this topic within 30 days, it becomes a permanent category!</p>
              </div>
            </div>
          </div>
        </div>
      )}

      {selectedCategory && (
        <div className="mt-8 text-center">
          <div className="inline-flex items-center px-4 py-2 bg-blue-100 text-blue-800 rounded-full">
            <span className="mr-2">Selected:</span>
            <span className="font-semibold">
              {selectedCategory === 'custom' ? customKeyword || 'Custom Topic' : keywordCategories.find(c => c.id === selectedCategory)?.title}
            </span>
          </div>
        </div>
      )}
    </div>
  );
} 
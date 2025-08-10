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
    icon: '💭'
  },
  {
    id: 'tech-rant' as KeywordCategory,
    title: 'Tech Rant',
    description: 'Software bugs, hardware issues, digital frustrations',
    icon: '💻'
  },
  {
    id: 'office-rant' as KeywordCategory,
    title: 'Office Rant',
    description: 'Work stress, colleagues, meetings, deadlines',
    icon: '🏢'
  },
  {
    id: 'social-rant' as KeywordCategory,
    title: 'Social Rant',
    description: 'Social media, relationships, society issues',
    icon: '👥'
  },
  {
    id: 'relationship-rant' as KeywordCategory,
    title: 'Relationship Rant',
    description: 'Dating, family, friendships, love life',
    icon: '❤️'
  },
  {
    id: 'health-rant' as KeywordCategory,
    title: 'Health Rant',
    description: 'Medical issues, fitness, wellness struggles',
    icon: '🏥'
  },
  {
    id: 'money-rant' as KeywordCategory,
    title: 'Money Rant',
    description: 'Financial stress, bills, investments, economy',
    icon: '💰'
  },
  {
    id: 'education-rant' as KeywordCategory,
    title: 'Education Rant',
    description: 'School, college, learning, academic stress',
    icon: '📚'
  },
  {
    id: 'politics-rant' as KeywordCategory,
    title: 'Politics Rant',
    description: 'Political views, current events, government',
    icon: '🗳️'
  },
  {
    id: 'entertainment-rant' as KeywordCategory,
    title: 'Entertainment Rant',
    description: 'Movies, music, games, pop culture',
    icon: '🎬'
  },
  {
    id: 'custom' as KeywordCategory,
    title: 'Custom Topic',
    description: 'Create your own rant category',
    icon: '✨'
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
    }
  };

  return (
    <div className="max-w-6xl mx-auto p-6">
      <div className="text-center mb-8">
        <h2 className="text-3xl font-bold theme-text mb-4">What's on your mind?</h2>
        <p className="text-lg theme-text-secondary">Pick a topic or create your own</p>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        {keywordCategories.map((category) => (
          <div
            key={category.id}
            onClick={() => handleCategorySelect(category.id)}
            className={`
              p-4 rounded-lg border-2 cursor-pointer transition-all duration-200 theme-card
              ${selectedCategory === category.id
                ? 'border-blue-500 shadow-lg scale-105'
                : 'hover:border-blue-300 hover:shadow-md'
              }
            `}
          >
            <div className="text-center">
              <div className="text-3xl mb-2">{category.icon}</div>
              <h3 className="font-semibold theme-text text-sm">{category.title}</h3>
              <p className="theme-text-secondary text-xs mt-1">{category.description}</p>
            </div>
          </div>
        ))}
      </div>

      {showCustomInput && (
        <div className="mt-8 max-w-md mx-auto">
          <div className="theme-card rounded-lg p-6">
            <h3 className="text-lg font-semibold theme-text mb-4">Create Your Own Topic</h3>
            <input
              type="text"
              value={customKeyword}
              onChange={(e) => onCustomKeywordChange(e.target.value)}
              placeholder="Enter your custom topic..."
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent theme-text bg-transparent"
            />
            <p className="text-sm theme-text-secondary mt-2">
              This will help us match you with someone who shares your interests.
            </p>
          </div>
        </div>
      )}

      {selectedCategory && (
        <div className="mt-8 text-center">
          <div className="inline-flex items-center px-4 py-2 theme-card border-2 border-purple-200 rounded-full">
            <span className="mr-2 theme-text-secondary">Selected:</span>
            <span className="font-semibold theme-text">
              {keywordCategories.find(c => c.id === selectedCategory)?.title}
              {selectedCategory === 'custom' && customKeyword && ` - ${customKeyword}`}
            </span>
          </div>
        </div>
      )}
    </div>
  );
} 

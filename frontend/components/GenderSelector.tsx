'use client';

import { useAppStore } from '@/lib/store';
import type { Gender } from '@/types';

const genders: { value: Gender; label: string }[] = [
  { value: 'male', label: 'Male' },
  { value: 'female', label: 'Female' },
  { value: 'other', label: 'Other' },
  { value: 'prefer-not-to-say', label: 'Prefer not to say' }
];

export default function GenderSelector() {
  const { setGender, setShowGenderSelector } = useAppStore();

  const handleGenderSelect = (gender: Gender) => {
    setGender(gender);
    setShowGenderSelector(false);
  };

  const handleSkip = () => {
    setGender('prefer-not-to-say');
    setShowGenderSelector(false);
  };

  return (
    <div className="max-w-md w-full mx-auto">
      <div className="bg-white rounded-lg shadow-lg p-6">
        <h2 className="text-xl font-semibold text-center mb-4">
          Select Your Gender
        </h2>
        <p className="text-sm text-gray-600 text-center mb-6">
          This helps us match you with compatible partners
        </p>
        
        <div className="space-y-3 mb-6">
          {genders.map((gender) => (
            <button
              key={gender.value}
              onClick={() => handleGenderSelect(gender.value)}
              className="w-full p-3 text-left bg-gray-50 border border-gray-200 rounded-lg hover:bg-gray-100 transition-colors"
            >
              {gender.label}
            </button>
          ))}
        </div>
        
        <button
          onClick={handleSkip}
          className="w-full p-3 text-gray-500 hover:text-gray-700 transition-colors"
        >
          Skip for now
        </button>
      </div>
    </div>
  );
} 
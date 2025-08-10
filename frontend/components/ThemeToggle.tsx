'use client';

import { useEffect, useState } from 'react';

type Theme = 'light' | 'dark' | 'system';

export default function ThemeToggle() {
  const [currentTheme, setCurrentTheme] = useState<Theme>('dark'); // Changed default to 'dark'

  useEffect(() => {
    // Load saved theme from localStorage
    const savedTheme = localStorage.getItem('rant-zone-theme') as Theme;
    if (savedTheme) {
      setCurrentTheme(savedTheme);
      applyTheme(savedTheme);
    } else {
      // If no saved theme, apply dark theme as default
      applyTheme('dark');
    }
  }, []);

  const applyTheme = (theme: Theme) => {
    const html = document.documentElement;
    
    // Remove all theme classes
    html.removeAttribute('data-theme');
    
    // Apply new theme
    if (theme === 'light' || theme === 'dark') {
      html.setAttribute('data-theme', theme);
    } else {
      html.setAttribute('data-theme', 'system');
    }
    
    // Save to localStorage
    localStorage.setItem('rant-zone-theme', theme);
    setCurrentTheme(theme);
  };

  const cycleTheme = () => {
    const themes: Theme[] = ['light', 'dark', 'system'];
    const currentIndex = themes.indexOf(currentTheme);
    const nextIndex = (currentIndex + 1) % themes.length;
    const nextTheme = themes[nextIndex];
    
    applyTheme(nextTheme);
  };

  return (
    <div className="theme-toggle-container">
      <button 
        onClick={cycleTheme}
        className="theme-toggle-btn"
        title={`Current theme: ${currentTheme}. Click to cycle themes.`}
      >
        {/* Light icon */}
        <svg 
          className={`w-6 h-6 ${currentTheme === 'light' ? '' : 'hidden'}`} 
          fill="currentColor" 
          viewBox="0 0 20 20"
        >
          <path fillRule="evenodd" d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z" clipRule="evenodd"></path>
        </svg>
        
        {/* Dark icon */}
        <svg 
          className={`w-6 h-6 ${currentTheme === 'dark' ? '' : 'hidden'}`} 
          fill="currentColor" 
          viewBox="0 0 20 20"
        >
          <path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z"></path>
        </svg>
        
        {/* System icon */}
        <svg 
          className={`w-6 h-6 ${currentTheme === 'system' ? '' : 'hidden'}`} 
          fill="currentColor" 
          viewBox="0 0 20 20"
        >
          <path fillRule="evenodd" d="M3 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clipRule="evenodd"></path>
        </svg>
      </button>
    </div>
  );
}

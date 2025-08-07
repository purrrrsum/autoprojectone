const crypto = require('crypto');

const BANNED_WORDS = [
  'spam', 'scam', 'hack', 'crack', 'warez', 'porn', 'xxx', 'adult',
  'casino', 'gambling', 'bet', 'lottery', 'viagra', 'cialis',
  'weight loss', 'diet pill', 'make money fast', 'work from home',
  'free money', 'lottery winner', 'inheritance', 'millionaire'
];

const SPAM_PATTERNS = [
  /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/, // Email
  /\bhttps?:\/\/[^\s]+/, // URLs
  /\b\d{3}[-.]?\d{3}[-.]?\d{4}\b/, // Phone numbers
  /\b\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4}\b/, // Credit card
];

function moderateContent(content) {
  if (!content || typeof content !== 'string') {
    return { isAllowed: false, reason: 'Invalid content' };
  }

  const lowerContent = content.toLowerCase();
  const flaggedWords = [];

  for (const word of BANNED_WORDS) {
    if (lowerContent.includes(word.toLowerCase())) {
      flaggedWords.push(word);
    }
  }

  for (const pattern of SPAM_PATTERNS) {
    if (pattern.test(content)) {
      return { isAllowed: false, reason: 'Contains spam patterns' };
    }
  }

  if (flaggedWords.length > 0) {
    return {
      isAllowed: false,
      reason: 'Contains banned words',
      flaggedWords
    };
  }

  if (content.length > 500) {
    return { isAllowed: false, reason: 'Message too long' };
  }

  if (content.trim().length === 0) {
    return { isAllowed: false, reason: 'Empty message' };
  }

  return { isAllowed: true };
}

function detectSpam(content, userId) {
  const redis = require('../database/connection').getRedisClient();
  const key = `spam:${userId}`;
  
  return redis.incr(key).then(count => {
    if (count === 1) {
      redis.expire(key, 60);
    }
    return count > 10;
  }).catch(() => false);
}

function hashContent(content) {
  return crypto.createHash('sha256').update(content).digest('hex');
}

module.exports = {
  moderateContent,
  detectSpam,
  hashContent
}; 
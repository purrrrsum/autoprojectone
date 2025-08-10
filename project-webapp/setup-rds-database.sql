-- Setup script for RDS PostgreSQL database
-- This script creates the database and applies the schema

-- Create the database (if it doesn't exist)
-- Note: We'll connect to the default 'postgres' database first
\c postgres;

-- Create the rant_zone database
CREATE DATABASE rant_zone;

-- Connect to the new database
\c rant_zone;

-- Updated Database Schema for 3-Layer Login System

-- Users table with enhanced preferences
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  user_id VARCHAR(255) UNIQUE NOT NULL,
  activity_level VARCHAR(20) NOT NULL CHECK (activity_level IN ('immediate', 'medium', 'long')),
  keyword_category VARCHAR(50) NOT NULL,
  custom_keyword VARCHAR(100),
  emotional_state VARCHAR(20) CHECK (emotional_state IN ('angry', 'sad', 'happy', 'frustrated', 'excited', 'anxious', 'calm', 'confused', 'grateful', 'hopeful', 'none')),
  gender VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  session_config JSONB -- Store session-specific configuration
);

-- Chat sessions with activity level matching
CREATE TABLE IF NOT EXISTS chat_sessions (
  id SERIAL PRIMARY KEY,
  session_id VARCHAR(255) UNIQUE NOT NULL,
  activity_level VARCHAR(20) NOT NULL,
  keyword_category VARCHAR(50) NOT NULL,
  custom_keyword VARCHAR(100),
  emotional_state VARCHAR(20),
  user1_id VARCHAR(255),
  user2_id VARCHAR(255),
  status VARCHAR(50) DEFAULT 'waiting',
  response_timeout INTEGER NOT NULL, -- Based on activity level
  session_timeout INTEGER NOT NULL, -- Based on activity level
  max_messages_per_minute INTEGER NOT NULL,
  auto_reconnect BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Messages with activity level context
CREATE TABLE IF NOT EXISTS messages (
  id SERIAL PRIMARY KEY,
  session_id VARCHAR(255) NOT NULL,
  sender_id VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  encrypted_content TEXT,
  message_type VARCHAR(20) DEFAULT 'text',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '30 days')
);

-- Keyword categories (including custom ones that become popular)
CREATE TABLE IF NOT EXISTS keyword_categories (
  id SERIAL PRIMARY KEY,
  category_id VARCHAR(50) UNIQUE NOT NULL,
  display_name VARCHAR(100) NOT NULL,
  description TEXT,
  icon VARCHAR(10),
  color_scheme VARCHAR(50),
  usage_count INTEGER DEFAULT 0,
  is_custom BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Custom keyword tracking for popularity
CREATE TABLE IF NOT EXISTS custom_keywords (
  id SERIAL PRIMARY KEY,
  keyword VARCHAR(100) NOT NULL,
  usage_count INTEGER DEFAULT 1,
  first_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_promoted BOOLEAN DEFAULT false, -- Becomes permanent category if usage_count >= 10
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Emotional state tracking
CREATE TABLE IF NOT EXISTS emotional_states (
  id SERIAL PRIMARY KEY,
  state_id VARCHAR(20) UNIQUE NOT NULL,
  display_name VARCHAR(50) NOT NULL,
  description TEXT,
  icon VARCHAR(10),
  color_scheme VARCHAR(50),
  usage_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Session activity tracking
CREATE TABLE IF NOT EXISTS session_activity (
  id SERIAL PRIMARY KEY,
  session_id VARCHAR(255) NOT NULL,
  user_id VARCHAR(255) NOT NULL,
  activity_type VARCHAR(50) NOT NULL, -- 'join', 'message', 'leave', 'timeout'
  activity_data JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Moderation reports with context
CREATE TABLE IF NOT EXISTS moderation_reports (
  id SERIAL PRIMARY KEY,
  session_id VARCHAR(255) NOT NULL,
  reporter_id VARCHAR(255) NOT NULL,
  reported_user_id VARCHAR(255) NOT NULL,
  reason VARCHAR(100) NOT NULL,
  details TEXT,
  activity_level VARCHAR(20), -- Context of the session
  keyword_category VARCHAR(50), -- Context of the session
  status VARCHAR(20) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP
);

-- User activity analytics
CREATE TABLE IF NOT EXISTS user_activity (
  id SERIAL PRIMARY KEY,
  user_id VARCHAR(255) NOT NULL,
  activity_level VARCHAR(20) NOT NULL,
  keyword_category VARCHAR(50) NOT NULL,
  emotional_state VARCHAR(20),
  session_duration INTEGER, -- in seconds
  messages_sent INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- System statistics
CREATE TABLE IF NOT EXISTS system_stats (
  id SERIAL PRIMARY KEY,
  stat_date DATE NOT NULL,
  total_users INTEGER DEFAULT 0,
  active_sessions INTEGER DEFAULT 0,
  messages_sent INTEGER DEFAULT 0,
  activity_level_distribution JSONB, -- {'immediate': 30, 'medium': 45, 'long': 25}
  keyword_category_distribution JSONB,
  emotional_state_distribution JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_activity_level ON users(activity_level);
CREATE INDEX IF NOT EXISTS idx_users_keyword_category ON users(keyword_category);
CREATE INDEX IF NOT EXISTS idx_users_emotional_state ON users(emotional_state);
CREATE INDEX IF NOT EXISTS idx_chat_sessions_activity_level ON chat_sessions(activity_level);
CREATE INDEX IF NOT EXISTS idx_chat_sessions_keyword_category ON chat_sessions(keyword_category);
CREATE INDEX IF NOT EXISTS idx_chat_sessions_status ON chat_sessions(status);
CREATE INDEX IF NOT EXISTS idx_messages_session_id ON messages(session_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_custom_keywords_usage_count ON custom_keywords(usage_count);
CREATE INDEX IF NOT EXISTS idx_session_activity_session_id ON session_activity(session_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_user_id ON user_activity(user_id);

-- Functions for automatic cleanup and statistics
CREATE OR REPLACE FUNCTION cleanup_expired_messages()
RETURNS void AS $$
BEGIN
  DELETE FROM messages WHERE expires_at < CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_custom_keyword_usage()
RETURNS trigger AS $$
BEGIN
  -- Update usage count for custom keywords
  INSERT INTO custom_keywords (keyword, usage_count, last_used)
  VALUES (NEW.custom_keyword, 1, CURRENT_TIMESTAMP)
  ON CONFLICT (keyword) 
  DO UPDATE SET 
    usage_count = custom_keywords.usage_count + 1,
    last_used = CURRENT_TIMESTAMP;
  
  -- Check if keyword should be promoted (10+ uses in 30 days)
  UPDATE custom_keywords 
  SET is_promoted = true 
  WHERE keyword = NEW.custom_keyword 
    AND usage_count >= 10 
    AND last_used >= CURRENT_TIMESTAMP - INTERVAL '30 days'
    AND is_promoted = false;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically track custom keyword usage
CREATE TRIGGER track_custom_keyword_usage
  AFTER INSERT ON users
  FOR EACH ROW
  WHEN (NEW.custom_keyword IS NOT NULL)
  EXECUTE FUNCTION update_custom_keyword_usage();

-- Insert default keyword categories
INSERT INTO keyword_categories (category_id, display_name, description, icon, color_scheme) VALUES
('personal-feelings', 'Personal Feelings', 'Deep emotions, life struggles, personal growth', '💭', 'purple'),
('tech-rant', 'Tech Rant', 'Software bugs, hardware issues, digital frustrations', '💻', 'blue'),
('office-rant', 'Office Rant', 'Work stress, colleagues, meetings, deadlines', '🏢', 'gray'),
('social-rant', 'Social Rant', 'Social media, relationships, society issues', '👥', 'green'),
('relationship-rant', 'Relationship Rant', 'Dating, family, friendships, love life', '❤️', 'pink'),
('health-rant', 'Health Rant', 'Medical issues, fitness, wellness struggles', '🏥', 'red'),
('money-rant', 'Money Rant', 'Financial stress, bills, investments, economy', '💰', 'yellow'),
('education-rant', 'Education Rant', 'School, college, learning, academic stress', '📚', 'indigo'),
('politics-rant', 'Politics Rant', 'Political views, current events, government', '🗳️', 'orange'),
('entertainment-rant', 'Entertainment Rant', 'Movies, music, games, pop culture', '🎬', 'teal')
ON CONFLICT (category_id) DO NOTHING;

-- Insert default emotional states
INSERT INTO emotional_states (state_id, display_name, description, icon, color_scheme) VALUES
('angry', 'Angry', 'Frustrated, irritated, mad', '😠', 'red'),
('sad', 'Sad', 'Depressed, lonely, down', '😢', 'blue'),
('happy', 'Happy', 'Joyful, excited, positive', '😊', 'yellow'),
('frustrated', 'Frustrated', 'Annoyed, stressed, overwhelmed', '😤', 'orange'),
('excited', 'Excited', 'Energetic, enthusiastic, pumped', '🤩', 'pink'),
('anxious', 'Anxious', 'Worried, nervous, tense', '😰', 'purple'),
('calm', 'Calm', 'Peaceful, relaxed, serene', '😌', 'green'),
('confused', 'Confused', 'Lost, uncertain, puzzled', '😵', 'gray'),
('grateful', 'Grateful', 'Thankful, appreciative, blessed', '🙏', 'teal'),
('hopeful', 'Hopeful', 'Optimistic, positive, looking forward', '✨', 'indigo')
ON CONFLICT (state_id) DO NOTHING;

-- Grant permissions to the postgres user
GRANT ALL PRIVILEGES ON DATABASE rant_zone TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;

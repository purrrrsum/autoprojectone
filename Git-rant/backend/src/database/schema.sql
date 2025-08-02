-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id VARCHAR(255) UNIQUE NOT NULL,
  interest VARCHAR(50) NOT NULL CHECK (interest IN ('science', 'tech', 'politics', 'personal')),
  is_online BOOLEAN DEFAULT false,
  last_seen TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Chat sessions table
CREATE TABLE chat_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  interest VARCHAR(50) NOT NULL CHECK (interest IN ('science', 'tech', 'politics', 'personal')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  CHECK (user1_id != user2_id)
);

-- Messages table
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_session_id UUID NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  encrypted_content TEXT NOT NULL,
  content_hash VARCHAR(64) NOT NULL,
  moderation_status VARCHAR(20) DEFAULT 'pending' CHECK (moderation_status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP DEFAULT (NOW() + INTERVAL '30 days')
);

-- Interests table
CREATE TABLE interests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(50) UNIQUE NOT NULL CHECK (name IN ('science', 'tech', 'politics', 'personal')),
  active_users INTEGER DEFAULT 0,
  total_sessions INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Moderation reports table
CREATE TABLE moderation_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  message_id UUID REFERENCES messages(id) ON DELETE CASCADE,
  reporter_id UUID REFERENCES users(id) ON DELETE CASCADE,
  reason VARCHAR(255) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'resolved', 'dismissed')),
  created_at TIMESTAMP DEFAULT NOW()
);

-- User activity table
CREATE TABLE user_activity (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  action VARCHAR(50) NOT NULL,
  details JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

-- System stats table
CREATE TABLE system_stats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  total_users INTEGER DEFAULT 0,
  active_sessions INTEGER DEFAULT 0,
  total_messages INTEGER DEFAULT 0,
  messages_24h INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_users_session_id ON users(session_id);
CREATE INDEX idx_users_interest ON users(interest);
CREATE INDEX idx_users_online ON users(is_online) WHERE is_online = true;
CREATE INDEX idx_chat_sessions_users ON chat_sessions(user1_id, user2_id);
CREATE INDEX idx_chat_sessions_active ON chat_sessions(is_active) WHERE is_active = true;
CREATE INDEX idx_messages_session ON messages(chat_session_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_expires ON messages(expires_at);
CREATE INDEX idx_messages_created ON messages(created_at);
CREATE INDEX idx_user_activity_user ON user_activity(user_id);
CREATE INDEX idx_user_activity_created ON user_activity(created_at);

-- Function to update user activity
CREATE OR REPLACE FUNCTION log_user_activity(user_uuid UUID, action_name VARCHAR(50), action_details JSONB DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
  INSERT INTO user_activity (user_id, action, details)
  VALUES (user_uuid, action_name, action_details);
END;
$$ LANGUAGE plpgsql;

-- Function to cleanup expired messages
CREATE OR REPLACE FUNCTION cleanup_expired_messages()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM messages WHERE expires_at < NOW();
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to update system stats
CREATE OR REPLACE FUNCTION update_system_stats()
RETURNS VOID AS $$
BEGIN
  INSERT INTO system_stats (
    total_users,
    active_sessions,
    total_messages,
    messages_24h
  )
  SELECT
    (SELECT COUNT(*) FROM users),
    (SELECT COUNT(*) FROM chat_sessions WHERE is_active = true),
    (SELECT COUNT(*) FROM messages),
    (SELECT COUNT(*) FROM messages WHERE created_at > NOW() - INTERVAL '24 hours')
  ON CONFLICT DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update user's last_seen
CREATE OR REPLACE FUNCTION update_user_last_seen()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_last_seen
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_user_last_seen();

-- Trigger to update chat session's updated_at
CREATE OR REPLACE FUNCTION update_chat_session_updated()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_chat_session_updated
  BEFORE UPDATE ON chat_sessions
  FOR EACH ROW
  EXECUTE FUNCTION update_chat_session_updated();

-- Insert default interests
INSERT INTO interests (name) VALUES 
  ('science'),
  ('tech'),
  ('politics'),
  ('personal')
ON CONFLICT (name) DO NOTHING; 
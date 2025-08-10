const { Client } = require('pg');

async function setupDatabase() {
  console.log('Starting database setup...');
  
  // Connect to the default postgres database first
  const client = new Client({
    host: 'rant-zone-db.cod0y2888f5c.us-east-1.rds.amazonaws.com',
    port: 5432,
    user: 'postgres',
    password: 'RantZone2024!',
    database: 'postgres'
  });

  try {
    console.log('Connecting to RDS postgres database...');
    await client.connect();
    
    // Check if rant_zone database exists
    const result = await client.query("SELECT 1 FROM pg_database WHERE datname = 'rant_zone'");
    
    if (result.rows.length === 0) {
      console.log('Creating rant_zone database...');
      await client.query('CREATE DATABASE rant_zone');
      console.log('Database created successfully!');
    } else {
      console.log('Database rant_zone already exists.');
    }
    
    await client.end();
    
    // Now connect to the rant_zone database
    const rantZoneClient = new Client({
      host: 'rant-zone-db.cod0y2888f5c.us-east-1.rds.amazonaws.com',
      port: 5432,
      user: 'postgres',
      password: 'RantZone2024!',
      database: 'rant_zone'
    });
    
    console.log('Connecting to rant_zone database...');
    await rantZoneClient.connect();
    
    // Create basic tables
    console.log('Creating tables...');
    
    // Users table
    await rantZoneClient.query(`
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
        session_config JSONB
      )
    `);
    console.log('Users table created/verified');
    
    // Chat sessions table
    await rantZoneClient.query(`
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
        response_timeout INTEGER NOT NULL,
        session_timeout INTEGER NOT NULL,
        max_messages_per_minute INTEGER NOT NULL,
        auto_reconnect BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('Chat sessions table created/verified');
    
    // Messages table
    await rantZoneClient.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id SERIAL PRIMARY KEY,
        session_id VARCHAR(255) NOT NULL,
        sender_id VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        encrypted_content TEXT,
        message_type VARCHAR(20) DEFAULT 'text',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '30 days')
      )
    `);
    console.log('Messages table created/verified');
    
    // Keyword categories table
    await rantZoneClient.query(`
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
      )
    `);
    console.log('Keyword categories table created/verified');
    
    // Insert default keyword categories
    await rantZoneClient.query(`
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
      ON CONFLICT (category_id) DO NOTHING
    `);
    console.log('Default keyword categories inserted');
    
    console.log('Database setup completed successfully!');
    await rantZoneClient.end();
    
  } catch (error) {
    console.error('Error setting up database:', error);
    try {
      await client.end();
    } catch (e) {
      // Ignore
    }
  }
}

setupDatabase();

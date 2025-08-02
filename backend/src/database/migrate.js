const { setupDatabase, getPgPool } = require('./connection');
const fs = require('fs').promises;
const path = require('path');

async function runMigrations() {
  try {
    console.log('🔄 Starting database migrations...');
    
    // Setup database connection
    await setupDatabase();
    const pool = getPgPool();
    
    // Read and execute schema
    const schemaPath = path.join(__dirname, 'schema.sql');
    const schema = await fs.readFile(schemaPath, 'utf8');
    
    const client = await pool.connect();
    
    try {
      // Split schema into individual statements
      const statements = schema
        .split(';')
        .map(stmt => stmt.trim())
        .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));
      
      for (const statement of statements) {
        if (statement.trim()) {
          await client.query(statement);
        }
      }
      
      console.log('✅ Database migrations completed successfully');
      
      // Insert initial data
      await insertInitialData(client);
      
    } finally {
      client.release();
    }
    
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

async function insertInitialData(client) {
  try {
    // Insert default interests
    const interests = ['science', 'tech', 'politics', 'personal'];
    
    for (const interest of interests) {
      await client.query(
        'INSERT INTO interests (name) VALUES ($1) ON CONFLICT (name) DO NOTHING',
        [interest]
      );
    }
    
    console.log('✅ Initial data inserted');
    
  } catch (error) {
    console.error('❌ Failed to insert initial data:', error);
  }
}

async function resetDatabase() {
  try {
    console.log('🔄 Resetting database...');
    
    await setupDatabase();
    const pool = getPgPool();
    const client = await pool.connect();
    
    try {
      // Drop all tables
      await client.query(`
        DROP TABLE IF EXISTS 
          user_activity,
          moderation_reports,
          messages,
          chat_sessions,
          users,
          interests,
          system_stats
        CASCADE;
      `);
      
      console.log('✅ Database reset completed');
      
      // Run migrations again
      await runMigrations();
      
    } finally {
      client.release();
    }
    
  } catch (error) {
    console.error('❌ Database reset failed:', error);
    process.exit(1);
  }
}

// CLI interface
const command = process.argv[2];

switch (command) {
  case 'migrate':
    runMigrations();
    break;
  case 'reset':
    resetDatabase();
    break;
  default:
    console.log('Usage: node migrate.js [migrate|reset]');
    process.exit(1);
} 
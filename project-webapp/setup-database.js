const { Client } = require('pg');
const fs = require('fs');

async function setupDatabase() {
  // Connect to the default postgres database first
  const client = new Client({
    host: 'rant-zone-db.cod0y2888f5c.us-east-1.rds.amazonaws.com',
    port: 5432,
    user: 'postgres',
    password: 'RantZone2024!',
    database: 'postgres'
  });

  try {
    console.log('Connecting to RDS...');
    await client.connect();
    
    // Create the rant_zone database
    console.log('Creating rant_zone database...');
    await client.query('CREATE DATABASE rant_zone');
    console.log('Database created successfully!');
    
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
    
    // Read and execute the schema
    console.log('Applying database schema...');
    const schema = fs.readFileSync('setup-rds-database.sql', 'utf8');
    
    // Split the schema into individual statements and execute them
    const statements = schema
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--') && !stmt.startsWith('\\c'));
    
    for (const statement of statements) {
      if (statement.trim()) {
        try {
          await rantZoneClient.query(statement);
          console.log('Executed:', statement.substring(0, 50) + '...');
        } catch (error) {
          if (!error.message.includes('already exists')) {
            console.error('Error executing statement:', error.message);
          }
        }
      }
    }
    
    console.log('Database setup completed successfully!');
    await rantZoneClient.end();
    
  } catch (error) {
    console.error('Error setting up database:', error);
    await client.end();
  }
}

setupDatabase();

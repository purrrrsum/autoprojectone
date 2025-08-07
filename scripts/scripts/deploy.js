#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Load configuration
const configPath = path.join(__dirname, '../config/auth-config.json');
const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

console.log('🚀 Starting deployment process...');

// Validate configuration
function validateConfig() {
  const required = [
    'database.railway.url',
    'redis.upstash.url',
    'security.jwt_secret',
    'security.encryption_key',
    'vercel.token',
    'flyio.api_token'
  ];

  for (const field of required) {
    const value = field.split('.').reduce((obj, key) => obj?.[key], config);
    if (!value || value.includes('your-')) {
      throw new Error(`Missing or invalid configuration: ${field}`);
    }
  }
}

// Deploy to Vercel
async function deployToVercel() {
  console.log('📦 Deploying to Vercel...');
  
  try {
    // Set Vercel environment variables
    const envVars = config.vercel.environment;
    for (const [key, value] of Object.entries(envVars)) {
      execSync(`vercel env add ${key} production ${value}`, { stdio: 'inherit' });
    }

    // Deploy
    execSync('vercel --prod', { 
      stdio: 'inherit',
      cwd: path.join(__dirname, '../frontend')
    });
    
    console.log('✅ Vercel deployment completed');
  } catch (error) {
    console.error('❌ Vercel deployment failed:', error.message);
    throw error;
  }
}

// Deploy to Fly.io
async function deployToFlyIO() {
  console.log('🛩️  Deploying to Fly.io...');
  
  try {
    // Set Fly.io secrets
    const secrets = {
      'DATABASE_URL': config.database.railway.url,
      'REDIS_URL': config.redis.upstash.url,
      'JWT_SECRET': config.security.jwt_secret,
      'ENCRYPTION_KEY': config.security.encryption_key,
      'NODE_ENV': 'production',
      'PORT': config.server.port.toString(),
      'HOST': config.server.host,
      'LOG_LEVEL': config.server.log_level
    };

    for (const [key, value] of Object.entries(secrets)) {
      execSync(`fly secrets set ${key}="${value}"`, { stdio: 'inherit' });
    }

    // Deploy
    execSync('fly deploy', { 
      stdio: 'inherit',
      cwd: path.join(__dirname, '../backend')
    });
    
    console.log('✅ Fly.io deployment completed');
  } catch (error) {
    console.error('❌ Fly.io deployment failed:', error.message);
    throw error;
  }
}

// Update DNS records
async function updateDNS() {
  console.log('🌐 Updating DNS records...');
  
  // This would typically be done through your DNS provider's API
  // For now, we'll just log the required records
  console.log('Required DNS records:');
  console.log(`A record: @ -> 76.76.21.21 (Vercel)`);
  console.log(`CNAME record: api -> ${config.flyio.app_name}.fly.dev`);
}

// Main deployment function
async function deploy() {
  try {
    validateConfig();
    
    await deployToVercel();
    await deployToFlyIO();
    await updateDNS();
    
    console.log('🎉 Deployment completed successfully!');
    console.log(`Frontend: ${config.domains.frontend_url}`);
    console.log(`Backend: ${config.domains.backend_url}`);
    
  } catch (error) {
    console.error('💥 Deployment failed:', error.message);
    process.exit(1);
  }
}

// Run deployment if called directly
if (require.main === module) {
  deploy();
}

module.exports = { deploy, validateConfig }; 
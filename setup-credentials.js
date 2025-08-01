#!/usr/bin/env node

const crypto = require('crypto');

console.log('🔐 Rant.Zone Credentials Generator\n');

// Generate JWT Secret
const jwtSecret = crypto.randomBytes(32).toString('hex');
console.log('JWT Secret:');
console.log(jwtSecret);
console.log('');

// Generate Encryption Key
const encryptionKey = crypto.randomBytes(32).toString('base64');
console.log('Encryption Key:');
console.log(encryptionKey);
console.log('');

// Generate Database Password
const dbPassword = crypto.randomBytes(16).toString('hex');
console.log('Database Password (if needed):');
console.log(dbPassword);
console.log('');

console.log('📋 Next Steps:');
console.log('1. Copy these keys to your GitHub Secrets');
console.log('2. Use them in your hosting platform environment variables');
console.log('3. Keep them secure and never commit them to version control');
console.log('');

console.log('🔗 Quick Links:');
console.log('- Railway (Database): https://railway.app');
console.log('- Upstash (Redis): https://upstash.com');
console.log('- Vercel (Frontend): https://vercel.com');
console.log('- Fly.io (Backend): https://fly.io');
console.log('- Cloudflare (DNS): https://cloudflare.com');
console.log('');

console.log('📖 Full Setup Guide: CREDENTIALS_SETUP_GUIDE.md'); 
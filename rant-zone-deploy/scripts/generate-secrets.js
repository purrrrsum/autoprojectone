#!/usr/bin/env node

const crypto = require('crypto');

console.log('🔐 Generating Secure Secrets');
console.log('============================\n');

// Generate JWT Secret (256-bit random string)
const jwtSecret = crypto.randomBytes(32).toString('hex');
console.log('JWT_SECRET:');
console.log(jwtSecret);
console.log('');

// Generate Encryption Key (256-bit base64 encoded)
const encryptionKey = crypto.randomBytes(32).toString('base64');
console.log('ENCRYPTION_KEY:');
console.log(encryptionKey);
console.log('');

// Generate bcrypt salt rounds (recommended: 12)
const bcryptRounds = 12;
console.log('BCRYPT_ROUNDS:');
console.log(bcryptRounds);
console.log('');

console.log('📋 Copy these values to your auth-config.json file:');
console.log('==================================================');
console.log(`"jwt_secret": "${jwtSecret}",`);
console.log(`"encryption_key": "${encryptionKey}",`);
console.log(`"bcrypt_rounds": ${bcryptRounds}`);
console.log('');

console.log('⚠️  Keep these secrets secure and never commit them to version control!');
console.log('💡 Use GitHub Secrets for production deployment.'); 
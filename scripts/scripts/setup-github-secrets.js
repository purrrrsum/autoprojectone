#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Load configuration
const configPath = path.join(__dirname, '../config/auth-config.json');
const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

console.log('🔐 GitHub Secrets Setup Guide');
console.log('=============================\n');

console.log('Add these secrets to your GitHub repository:');
console.log('Repository Settings → Secrets and variables → Actions → New repository secret\n');

// Vercel Secrets
console.log('📦 VERCEL SECRETS:');
console.log('VERCEL_TOKEN:', config.vercel.token);
console.log('VERCEL_PROJECT_ID:', config.vercel.project_id);
console.log('VERCEL_ORG_ID:', config.vercel.org_id);
console.log('');

// Fly.io Secrets
console.log('🛩️  FLY.IO SECRETS:');
console.log('FLY_API_TOKEN:', config.flyio.api_token);
console.log('FLY_APP_NAME:', config.flyio.app_name);
console.log('');

// Database Secrets
console.log('🗄️  DATABASE SECRETS:');
console.log('DATABASE_URL:', config.database.railway.url);
console.log('');

// Redis Secrets
console.log('🔴 REDIS SECRETS:');
console.log('REDIS_URL:', config.redis.upstash.url);
console.log('UPSTASH_REDIS_REST_TOKEN:', config.redis.upstash.rest_token);
console.log('');

// Security Secrets
console.log('🔒 SECURITY SECRETS:');
console.log('JWT_SECRET:', config.security.jwt_secret);
console.log('ENCRYPTION_KEY:', config.security.encryption_key);
console.log('');

// Environment Variables
console.log('🌍 ENVIRONMENT VARIABLES:');
console.log('NEXT_PUBLIC_API_URL:', config.vercel.environment.NEXT_PUBLIC_API_URL);
console.log('NEXT_PUBLIC_WEBSOCKET_URL:', config.vercel.environment.NEXT_PUBLIC_WEBSOCKET_URL);
console.log('NEXT_PUBLIC_APP_ENV:', config.vercel.environment.NEXT_PUBLIC_APP_ENV);
console.log('NEXT_PUBLIC_ENABLE_ANALYTICS:', config.vercel.environment.NEXT_PUBLIC_ENABLE_ANALYTICS);
console.log('');

console.log('📋 Copy and paste these values into GitHub Secrets for automated deployment.');
console.log('⚠️  Make sure to change the placeholder values in auth-config.json first!'); 
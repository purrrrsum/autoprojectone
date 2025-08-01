# GitHub Upload Guide for Rant.Zone

## Prerequisites
1. Git installed on your system (already installed via winget)
2. GitHub account
3. Restart your terminal/PowerShell to recognize Git

## Step-by-Step Instructions

### 1. Restart Your Terminal
Close and reopen your PowerShell/Command Prompt to ensure Git is recognized.

### 2. Initialize Git Repository
```bash
# Navigate to your project directory
cd C:\Users\USER\rant-zone

# Initialize Git repository
git init

# Verify Git is working
git --version
```

### 3. Configure Git (First time only)
```bash
# Set your GitHub username and email
git config --global user.name "Your GitHub Username"
git config --global user.email "your.email@example.com"
```

### 4. Add Files to Git
```bash
# Add all files to staging
git add .

# Check what files are staged
git status
```

### 5. Make Initial Commit
```bash
# Create initial commit
git commit -m "Initial commit: Rant.Zone anonymous ephemeral chat platform

- Complete Next.js frontend with TypeScript
- Fastify backend with WebSocket support
- PostgreSQL database schema
- Redis integration for caching
- End-to-end encryption
- Content moderation system
- CI/CD pipeline with GitHub Actions
- Docker configuration for deployment
- Comprehensive documentation"
```

### 6. Create GitHub Repository

#### Option A: Using GitHub Web Interface
1. Go to [GitHub.com](https://github.com)
2. Click the "+" icon in the top right
3. Select "New repository"
4. Repository name: `rant-zone`
5. Description: `Anonymous ephemeral chat platform with end-to-end encryption`
6. Make it **Public** (recommended for open source)
7. **DO NOT** initialize with README, .gitignore, or license (we already have these)
8. Click "Create repository"

#### Option B: Using GitHub CLI (if installed)
```bash
# Install GitHub CLI if not already installed
winget install GitHub.cli

# Login to GitHub
gh auth login

# Create repository
gh repo create rant-zone --public --description "Anonymous ephemeral chat platform with end-to-end encryption" --source=. --remote=origin --push
```

### 7. Connect to GitHub Repository
```bash
# Add remote origin (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/rant-zone.git

# Verify remote
git remote -v
```

### 8. Push to GitHub
```bash
# Push to main branch
git branch -M main
git push -u origin main
```

### 9. Verify Upload
1. Go to your GitHub repository: `https://github.com/YOUR_USERNAME/rant-zone`
2. Verify all files are uploaded correctly
3. Check that the README.md displays properly

## Repository Structure
Your GitHub repository should contain:
```
rant-zone/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── backend/
│   ├── src/
│   ├── Dockerfile
│   ├── fly.toml
│   ├── package.json
│   └── env.example
├── frontend/
│   ├── app/
│   ├── components/
│   ├── lib/
│   ├── types/
│   ├── package.json
│   └── env.example
├── docs/
│   ├── architecture.md
│   └── deployment_guide.md
├── .gitignore
├── README.md
├── PROJECT_STATUS.md
└── GITHUB_UPLOAD_GUIDE.md
```

## Next Steps After Upload

### 1. Set Up GitHub Secrets
Go to your repository → Settings → Secrets and variables → Actions, and add:
- `DATABASE_URL`
- `REDIS_URL`
- `JWT_SECRET`
- `ENCRYPTION_KEY`
- `FLY_API_TOKEN`
- `VERCEL_TOKEN`
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`
- `NEXT_PUBLIC_API_URL`
- `NEXT_PUBLIC_WEBSOCKET_URL`

### 2. Enable GitHub Actions
1. Go to Actions tab in your repository
2. Click "Enable Actions"
3. The CI/CD pipeline will run automatically on pushes to main

### 3. Set Up Branch Protection (Optional)
1. Go to Settings → Branches
2. Add rule for `main` branch
3. Enable "Require status checks to pass before merging"
4. Enable "Require branches to be up to date before merging"

## Troubleshooting

### Git Not Recognized
If Git is still not recognized after restarting terminal:
1. Check if Git is in PATH: `where git`
2. If not found, manually add Git to PATH:
   - Usually located at: `C:\Program Files\Git\bin`
   - Add to System Environment Variables

### Authentication Issues
If you get authentication errors:
1. Use GitHub CLI: `gh auth login`
2. Or set up SSH keys
3. Or use Personal Access Token

### Large File Issues
If you get errors about large files:
1. Check `.gitignore` is properly configured
2. Remove any large files from staging: `git reset HEAD <filename>`
3. Add large files to `.gitignore`

## Repository Features
Once uploaded, your repository will have:
- ✅ Complete source code
- ✅ CI/CD pipeline
- ✅ Comprehensive documentation
- ✅ Production-ready configuration
- ✅ Security best practices
- ✅ Performance optimizations

## Deployment Ready
After uploading to GitHub:
1. Connect to Vercel for frontend deployment
2. Connect to Fly.io for backend deployment
3. Set up PostgreSQL and Redis databases
4. Configure domain and SSL certificates

Your Rant.Zone project is now ready for production deployment! 🚀 
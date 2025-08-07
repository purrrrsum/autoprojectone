# Project WebApp - Advanced Anonymous Chat Platform

An advanced anonymous chat platform with optimizations, gender selection, and AWS deployment capabilities.

## 🚀 Features

- **Anonymous Chat**: Secure, anonymous real-time messaging
- **Gender Selection**: User preference-based matching
- **Interest Matching**: AI-powered user matching system
- **Real-time WebSocket**: Live chat functionality
- **AWS Deployment**: Complete cloud infrastructure setup
- **Docker Support**: Containerized deployment
- **Frontend**: Modern Next.js 14 with TypeScript
- **Backend**: Node.js with Fastify and WebSocket support

## 📁 Project Structure

```
project-webapp/
├── backend/                 # Node.js backend application
│   ├── src/
│   │   ├── database/       # Database schemas and migrations
│   │   ├── middleware/     # Authentication and middleware
│   │   ├── routes/         # API routes
│   │   ├── services/       # Business logic services
│   │   └── utils/          # Utility functions
│   ├── Dockerfile.aws      # AWS-optimized Dockerfile
│   └── package.json
├── frontend/               # Next.js frontend application
│   ├── app/               # Next.js 14 app directory
│   ├── components/        # React components
│   ├── lib/              # Utility libraries
│   ├── types/            # TypeScript type definitions
│   └── package.json
├── scripts/              # Deployment and utility scripts
├── docs/                 # Documentation files
├── infrastructure/       # Terraform and infrastructure configs
├── buildspec-optimized.yml  # AWS CodeBuild configuration
├── task-definition.json     # ECS task definition
└── README.md
```

## 🛠️ Technology Stack

### Backend
- **Runtime**: Node.js 18
- **Framework**: Fastify
- **Database**: PostgreSQL (Railway)
- **Cache**: Redis (Upstash)
- **Real-time**: WebSocket
- **Container**: Docker

### Frontend
- **Framework**: Next.js 14
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **State Management**: Zustand
- **Real-time**: WebSocket client

### Infrastructure
- **Cloud**: AWS (ECS, ECR, S3, CloudFront)
- **CI/CD**: AWS CodeBuild
- **Container Registry**: Amazon ECR
- **Load Balancer**: Application Load Balancer
- **CDN**: CloudFront

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Docker Desktop
- AWS CLI configured
- PostgreSQL database
- Redis instance

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd project-webapp
   ```

2. **Install dependencies**
   ```bash
   npm run install:all
   ```

3. **Setup environment variables**
   ```bash
   # Backend
   cd backend
   cp env.example .env
   # Configure your environment variables
   
   # Frontend
   cd ../frontend
   cp env.example .env.local
   # Configure your environment variables
   ```

4. **Start development servers**
   ```bash
   npm run dev
   ```

### Docker Development

```bash
# Start all services with Docker Compose
npm run docker:compose

# View logs
npm run docker:compose:logs

# Stop services
npm run docker:compose:down
```

## 🚀 AWS Deployment

### Prerequisites
- AWS Account with appropriate permissions
- AWS CLI configured
- Docker Desktop running

### Deployment Steps

1. **Setup IAM Permissions**
   ```powershell
   .\scripts\setup-iam-permissions.ps1
   ```

2. **Create CodeBuild Project**
   ```powershell
   .\scripts\setup-codebuild-simple.ps1
   ```

3. **Complete Deployment**
   ```powershell
   npm run aws:deploy:complete
   ```

4. **Deploy Frontend**
   ```powershell
   .\scripts\deploy-frontend-simple.ps1
   ```

## 📚 Documentation

- [AWS Backend Deployment Guide](docs/AWS_BACKEND_DEPLOYMENT_GUIDE.md)
- [AWS Credentials Setup](docs/AWS_CREDENTIALS_SETUP.md)
- [Complete Status Report](docs/COMPLETE_STATUS_REPORT.md)
- [Current Status](docs/CURRENT_STATUS.md)

## 🔧 Configuration

### Environment Variables

#### Backend (.env)
```env
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
JWT_SECRET=your-secret-key
PORT=3001
```

#### Frontend (.env.local)
```env
NEXT_PUBLIC_BACKEND_URL=http://localhost:3001
NEXT_PUBLIC_WS_URL=ws://localhost:3001
```

## 🐳 Docker

### Build Backend Image
```bash
cd backend
docker build -f Dockerfile.aws -t project-webapp-backend .
```

### Run with Docker Compose
```bash
docker-compose up -d
```

## 📊 Monitoring

- **CloudWatch Logs**: `/aws/codebuild/rant-zone-backend-build`
- **ECS Service**: Monitor container health and performance
- **Application Load Balancer**: Track request metrics

## 🔒 Security

- JWT-based authentication
- Environment variable encryption
- HTTPS enforcement
- Input validation and sanitization
- Rate limiting

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Check the [documentation](docs/)
- Review [deployment guides](docs/)
- Open an issue on GitHub

---

**Built with ❤️ using modern web technologies**

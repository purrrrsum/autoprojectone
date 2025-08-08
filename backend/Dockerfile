# Multi-stage build for AWS ECS deployment
FROM public.ecr.aws/amazonlinux/amazonlinux:2 AS builder

# Install Node.js 18
RUN curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
RUN yum install -y nodejs

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --omit=dev && npm cache clean --force

# Copy source code
COPY . .

# Create non-root user
RUN useradd -r -s /bin/false nodejs

# Production stage
FROM public.ecr.aws/amazonlinux/amazonlinux:2 AS production

# Install Node.js 18
RUN curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
RUN yum install -y nodejs

# Install dumb-init for proper signal handling
RUN curl -L -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64
RUN chmod +x /usr/local/bin/dumb-init

# Create app directory
WORKDIR /app

# Create non-root user
RUN useradd -r -s /bin/false nodejs

# Copy built application from builder stage
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/src ./src
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["node", "src/index.js"]

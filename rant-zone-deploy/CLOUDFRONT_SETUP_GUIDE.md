# CloudFront & Custom Domain Setup Guide

## 🚀 Step 1: Create CloudFront Distribution

### Via AWS Console:
1. **Go to AWS CloudFront Console**
   - Open: https://console.aws.amazon.com/cloudfront/
   - Click "Create Distribution"

2. **Origin Settings**
   - **Origin Domain**: `rant-zone-frontend-7115.s3-website-us-east-1.amazonaws.com`
   - **Origin Path**: (leave empty)
   - **Origin ID**: `S3-rant-zone-frontend`
   - **Origin Protocol**: `HTTP Only`

3. **Default Cache Behavior**
   - **Viewer Protocol Policy**: `Redirect HTTP to HTTPS`
   - **Allowed HTTP Methods**: `GET, HEAD, OPTIONS`
   - **Cached HTTP Methods**: `GET, HEAD`
   - **Compress Objects Automatically**: `Yes`
   - **Cache Policy**: `CachingOptimized`
   - **Origin Request Policy**: `CORS-S3Origin`

4. **Settings**
   - **Price Class**: `Use Only North America and Europe`
   - **Alternate Domain Names (CNAMEs)**: `rant.zone` and `www.rant.zone`
   - **SSL Certificate**: `Request a certificate`
   - **Default Root Object**: `index.html`
   - **Custom Error Responses**: Add 404 → `/index.html` (200)

5. **Create Distribution**
   - Click "Create Distribution"
   - Wait for deployment (5-10 minutes)

## 🌐 Step 2: Request SSL Certificate

### Via AWS Certificate Manager:
1. **Go to Certificate Manager**
   - Open: https://console.aws.amazon.com/acm/
   - Click "Request a certificate"

2. **Certificate Settings**
   - **Certificate type**: `Request a public certificate`
   - **Domain names**: 
     - `rant.zone`
     - `*.rant.zone`
   - **Validation method**: `DNS validation`

3. **Add Tags** (optional)
   - Key: `Project`
   - Value: `rant-zone`

4. **Request Certificate**
   - Click "Request"
   - Note the validation records

## 🔗 Step 3: Configure DNS in Hostinger

### DNS Records to Add:
1. **A Record for Root Domain**
   - **Type**: `A`
   - **Name**: `@`
   - **Value**: `[CloudFront Distribution IP]` (get from CloudFront console)
   - **TTL**: `300`

2. **CNAME for WWW**
   - **Type**: `CNAME`
   - **Name**: `www`
   - **Value**: `[CloudFront Distribution Domain]` (e.g., `d1234567890abc.cloudfront.net`)
   - **TTL**: `300`

3. **CNAME for API** (for backend)
   - **Type**: `CNAME`
   - **Name**: `api`
   - **Value**: `[Backend Load Balancer Domain]` (will be set later)
   - **TTL**: `300`

### SSL Certificate Validation:
- Add the CNAME records provided by AWS Certificate Manager
- Wait for validation (5-10 minutes)

## 🔄 Step 4: Update CloudFront Distribution

### After Certificate is Validated:
1. **Go back to CloudFront**
   - Select your distribution
   - Click "Edit"

2. **Update SSL Certificate**
   - **SSL Certificate**: Select your validated certificate
   - **Alternate Domain Names**: Add `rant.zone` and `www.rant.zone`

3. **Save Changes**
   - Click "Save Changes"
   - Wait for deployment

## 🧪 Step 5: Test the Setup

### Test URLs:
- `https://rant.zone` (should redirect to HTTPS)
- `https://www.rant.zone` (should work)
- `http://rant.zone` (should redirect to HTTPS)

### Expected Behavior:
- ✅ HTTPS redirect works
- ✅ Custom domain loads
- ✅ SSL certificate is valid
- ✅ Fast loading (CloudFront caching)

## 📋 Step 6: Update Application Configuration

### Update Environment Variables:
```bash
# Frontend
NEXT_PUBLIC_API_URL=https://api.rant.zone
NEXT_PUBLIC_WEBSOCKET_URL=wss://api.rant.zone

# Backend
ALLOWED_ORIGINS=https://rant.zone,https://www.rant.zone
```

## 🎯 Next Steps:
1. **Deploy Backend to ECS**
2. **Set up API Gateway or Load Balancer**
3. **Configure WebSocket connections**
4. **Set up monitoring and logging**

## 📞 Support:
If you encounter issues:
1. Check CloudFront distribution status
2. Verify DNS propagation (use https://dnschecker.org)
3. Check SSL certificate validation
4. Review CloudFront error logs 
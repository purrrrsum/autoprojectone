# GitHub Actions Setup Guide

## 🚀 Setting up GitHub Actions for AWS S3 Deployment

### Step 1: Push to GitHub
```bash
# Initialize git if not already done
git init
git add .
git commit -m "Add GitHub Actions workflow"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git push -u origin main
```

### Step 2: Add AWS Credentials to GitHub Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these secrets:

#### Required Secrets:
- **Name:** `AWS_ACCESS_KEY_ID`
- **Value:** `AKIATIVN6QTLJ6WF7VX2`

- **Name:** `AWS_SECRET_ACCESS_KEY`  
- **Value:** `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`

#### Optional Secret (for CloudFront):
- **Name:** `CLOUDFRONT_DISTRIBUTION_ID`
- **Value:** (Leave empty for now, add later when CloudFront is set up)

### Step 3: Trigger Deployment

The workflow will automatically run when you push to the `main` branch.

To manually trigger:
1. Go to **Actions** tab in your GitHub repo
2. Click **Deploy Frontend to AWS S3**
3. Click **Run workflow**

### Step 4: Monitor Deployment

1. Go to **Actions** tab
2. Click on the running workflow
3. Watch the build process
4. Check for any errors

### Step 5: Verify Deployment

After successful deployment, your site will be available at:
- **S3 Website URL:** http://rant-zone-frontend.s3-website-us-east-1.amazonaws.com

### Troubleshooting

#### Common Issues:

1. **Build fails with memory error:**
   - The GitHub Actions runner has 7GB RAM, should be enough
   - Check if there are any dependency conflicts

2. **AWS credentials error:**
   - Verify the secrets are correctly set
   - Check that the AWS user has S3 permissions

3. **S3 sync fails:**
   - Ensure the S3 bucket exists
   - Check bucket permissions

#### Permissions needed for AWS user:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::rant-zone-frontend",
                "arn:aws:s3:::rant-zone-frontend/*"
            ]
        }
    ]
}
```

### Next Steps

After successful frontend deployment:
1. Set up CloudFront distribution
2. Configure custom domain
3. Deploy backend to ECS
4. Set up CI/CD for backend

## 🎉 Success!

Your frontend will be automatically deployed to S3 every time you push to the main branch! 
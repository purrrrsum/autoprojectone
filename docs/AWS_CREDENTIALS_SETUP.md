# 🔐 AWS Credentials Setup Guide

## 📋 **What You Need for Automated Scripts**

### **Required Credentials:**
1. **AWS Access Key ID** (20 characters)
2. **AWS Secret Access Key** (40 characters)
3. **AWS Account ID** (12 digits)

### **Required Permissions:**
- **ECR** (Elastic Container Registry)
- **ECS** (Elastic Container Service)
- **SSM** (Systems Manager Parameter Store)
- **CloudWatch** (Logs)
- **IAM** (Basic permissions)

---

## 🚀 **Step-by-Step Setup**

### **Step 1: Create IAM User**

1. **Go to AWS IAM Console**: https://console.aws.amazon.com/iam/
2. **Click "Users"** in the left sidebar
3. **Click "Create user"**
4. **User name**: `rant-zone-deploy`
5. **Check "Programmatic access"**
6. **Click "Next: Permissions"**

### **Step 2: Attach Permissions**

#### **Option A: Attach Policy Directly**
1. **Click "Attach existing policies directly"**
2. **Search and select these policies:**
   - `AmazonEC2ContainerRegistryFullAccess`
   - `AmazonECS-FullAccess`
   - `AmazonSSMFullAccess`
   - `CloudWatchLogsFullAccess`

#### **Option B: Create Custom Policy (Recommended)**
1. **Click "Create policy"**
2. **Go to JSON tab**
3. **Paste this policy:**

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:*",
                "ecs:*",
                "ssm:PutParameter",
                "ssm:GetParameter",
                "ssm:DeleteParameter",
                "ssm:DescribeParameters",
                "logs:*",
                "iam:PassRole",
                "iam:GetRole",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeVpcs",
                "ec2:DescribeInstances"
            ],
            "Resource": "*"
        }
    ]
}
```

4. **Name**: `RantZoneDeploymentPolicy`
5. **Click "Create policy"**
6. **Go back to user creation**
7. **Attach the new policy**

### **Step 3: Create User**

1. **Click "Next: Tags"** (optional)
2. **Click "Next: Review"**
3. **Click "Create user"**
4. **IMPORTANT**: Download the CSV file with credentials!

### **Step 4: Configure AWS CLI**

Open PowerShell and run:

```bash
aws configure
```

**Enter the following:**
- **AWS Access Key ID**: Your access key from CSV
- **AWS Secret Access Key**: Your secret key from CSV
- **Default region name**: `us-east-1`
- **Default output format**: `json`

### **Step 5: Test Your Setup**

Run the test script:

```bash
.\scripts\test-aws-credentials.ps1
```

---

## 🔍 **Verification Checklist**

### **✅ Before Running Deployment Scripts:**

- [ ] **AWS CLI installed**
- [ ] **AWS credentials configured**
- [ ] **IAM user created with proper permissions**
- [ ] **Docker Desktop installed and running**
- [ ] **Test script passes all checks**

### **✅ Test Script Should Show:**
```
✅ AWS CLI found: aws-cli/2.x.x
✅ AWS credentials found: arn:aws:iam::123456789012:user/rant-zone-deploy
   Account ID: 123456789012
✅ ECR permissions OK
✅ ECS permissions OK
✅ SSM permissions OK
✅ CloudWatch permissions OK
✅ Docker found: Docker version 20.x.x
```

---

## 🚨 **Common Issues & Solutions**

### **Issue 1: "Access Denied" Errors**
**Solution**: Check IAM permissions
- Ensure user has all required policies
- Verify policy JSON is correct
- Check if user is in correct AWS account

### **Issue 2: "AWS CLI not found"**
**Solution**: Install AWS CLI
```bash
# Download from: https://aws.amazon.com/cli/
# Or use winget:
winget install Amazon.AWSCLI
```

### **Issue 3: "Docker not found"**
**Solution**: Install Docker Desktop
- Download from: https://www.docker.com/products/docker-desktop
- Start Docker Desktop
- Wait for Docker to be ready

### **Issue 4: "Invalid credentials"**
**Solution**: Reconfigure AWS CLI
```bash
aws configure
# Enter correct Access Key ID and Secret Access Key
```

---

## 🔒 **Security Best Practices**

### **✅ Do:**
- Use IAM users (not root account)
- Grant minimum required permissions
- Rotate access keys regularly
- Use AWS CLI profiles for multiple accounts

### **❌ Don't:**
- Share credentials in code
- Use root account credentials
- Grant excessive permissions
- Commit credentials to Git

---

## 📞 **Support**

### **If you encounter issues:**

1. **Check AWS Console** for IAM user status
2. **Verify permissions** in IAM console
3. **Test credentials** with simple AWS commands
4. **Check Docker** is running
5. **Review error messages** carefully

### **Useful Commands:**
```bash
# Test AWS credentials
aws sts get-caller-identity

# List ECR repositories
aws ecr describe-repositories --region us-east-1

# List ECS clusters
aws ecs list-clusters --region us-east-1

# Test SSM
aws ssm describe-parameters --region us-east-1 --max-items 1
```

---

## 🎯 **Next Steps**

Once your credentials are set up:

1. **Run test script**: `.\scripts\test-aws-credentials.ps1`
2. **If all tests pass**: Run deployment script
3. **If any tests fail**: Fix the issues first

**Ready to proceed? Let me know when your credentials are configured!** 
# S3 Backend Setup Guide

## 🎯 What is S3 Backend?

S3 backend stores your Terraform state file in AWS S3 instead of locally. This enables:

✅ **Team Collaboration** - Multiple team members can work on the same infrastructure  
✅ **State Locking** - Prevents concurrent modifications using DynamoDB  
✅ **Backup & Versioning** - Automatic backups and version history  
✅ **Remote Access** - Access state from anywhere  
✅ **Security** - Encryption at rest and in transit  

---

## 📋 Prerequisites

- AWS CLI configured with `neerajnakka.n@gmail.com` profile
- PowerShell (for running setup script)
- Terraform installed

---

## 🚀 Quick Setup (Automated)

### **Option 1: Run Setup Script (Recommended)**

```powershell
cd task10-blue-green
.\setup-s3-backend.ps1
```

This script will:
1. Create S3 bucket
2. Enable versioning
3. Enable encryption
4. Block public access
5. Create DynamoDB table for state locking

Then initialize Terraform:
```bash
cd terraform
terraform init
```

---

## 🛠️ Manual Setup (Step by Step)

### **Step 1: Create S3 Bucket**

```bash
aws s3api create-bucket \
  --bucket neeraj-strapi-task10-state \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1 \
  --profile neerajnakka.n@gmail.com
```

### **Step 2: Enable Versioning**

```bash
aws s3api put-bucket-versioning \
  --bucket neeraj-strapi-task10-state \
  --versioning-configuration Status=Enabled \
  --profile neerajnakka.n@gmail.com
```

### **Step 3: Enable Encryption**

```bash
aws s3api put-bucket-encryption \
  --bucket neeraj-strapi-task10-state \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }' \
  --profile neerajnakka.n@gmail.com
```

### **Step 4: Block Public Access**

```bash
aws s3api put-public-access-block \
  --bucket neeraj-strapi-task10-state \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
  --profile neerajnakka.n@gmail.com
```

### **Step 5: Create DynamoDB Table for State Locking**

```bash
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region ap-south-1 \
  --profile neerajnakka.n@gmail.com
```

### **Step 6: Initialize Terraform**

```bash
cd task10-blue-green/terraform
terraform init
```

---

## 📁 Backend Configuration

The backend is configured in `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "neeraj-strapi-task10-state"
    key            = "task10-blue-green/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    profile        = "neerajnakka.n@gmail.com"
  }
}
```

---

## 🔒 State Locking

State locking prevents concurrent modifications:

**How it works:**
1. When you run `terraform apply`, Terraform acquires a lock in DynamoDB
2. Other team members cannot modify the state while locked
3. Lock is released when operation completes
4. If operation fails, lock is released after timeout

**View locks:**
```bash
aws dynamodb scan \
  --table-name terraform-locks \
  --profile neerajnakka.n@gmail.com
```

**Force unlock (if needed):**
```bash
terraform force-unlock <LOCK_ID>
```

---

## 📊 S3 Bucket Structure

```
neeraj-strapi-task10-state/
└── task10-blue-green/
    ├── terraform.tfstate (current state)
    └── terraform.tfstate.backup (previous state)
```

---

## 🔐 Security Best Practices

✅ **Encryption** - State file encrypted at rest (AES256)  
✅ **Versioning** - All versions kept for recovery  
✅ **Public Access Blocked** - No public access allowed  
✅ **State Locking** - DynamoDB prevents concurrent access  
✅ **IAM Permissions** - Only your profile can access  

---

## 🚀 Deployment with S3 Backend

Once backend is configured:

```bash
cd task10-blue-green/terraform

# Initialize (migrates state to S3)
terraform init

# Plan
terraform plan

# Apply
terraform apply -auto-approve
```

---

## 📝 Troubleshooting

### **Error: "Bucket already exists"**
```
Solution: Use a different bucket name or delete the existing bucket
```

### **Error: "Access Denied"**
```
Solution: Verify AWS credentials and IAM permissions
aws sts get-caller-identity --profile neerajnakka.n@gmail.com
```

### **Error: "DynamoDB table already exists"**
```
Solution: Use a different table name or delete the existing table
```

### **State Lock Stuck**
```
Solution: Force unlock
terraform force-unlock <LOCK_ID>
```

---

## 🔄 Migrating from Local to S3

If you already have local state:

```bash
cd task10-blue-green/terraform

# Backup local state
cp terraform.tfstate terraform.tfstate.backup

# Initialize with S3 backend
terraform init

# Terraform will ask to migrate state
# Type 'yes' to confirm
```

---

## 💾 Backup & Recovery

### **Backup State**
```bash
aws s3 cp s3://neeraj-strapi-task10-state/task10-blue-green/terraform.tfstate \
  ./terraform.tfstate.backup \
  --profile neerajnakka.n@gmail.com
```

### **Restore State**
```bash
aws s3 cp ./terraform.tfstate.backup \
  s3://neeraj-strapi-task10-state/task10-blue-green/terraform.tfstate \
  --profile neerajnakka.n@gmail.com
```

### **View State History**
```bash
aws s3api list-object-versions \
  --bucket neeraj-strapi-task10-state \
  --prefix task10-blue-green/ \
  --profile neerajnakka.n@gmail.com
```

---

## 📊 Cost Estimation

**Monthly Cost (Approximate):**
- S3 Storage: ~$0.02 (state file is small)
- DynamoDB: ~$1.25 (on-demand pricing)
- **Total: ~$1.27/month**

---

## ✅ Verification

After setup, verify everything is working:

```bash
# Check S3 bucket
aws s3 ls s3://neeraj-strapi-task10-state/ \
  --profile neerajnakka.n@gmail.com

# Check DynamoDB table
aws dynamodb describe-table \
  --table-name terraform-locks \
  --region ap-south-1 \
  --profile neerajnakka.n@gmail.com

# Check Terraform state
cd task10-blue-green/terraform
terraform state list
```

---

## 🎓 Learning Resources

- [Terraform S3 Backend Documentation](https://www.terraform.io/language/settings/backends/s3)
- [AWS S3 Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/BestPractices.html)
- [DynamoDB State Locking](https://www.terraform.io/language/settings/backends/s3#dynamodb_table)

---

## 📞 Quick Reference

| Command | Purpose |
|---------|---------|
| `./setup-s3-backend.ps1` | Automated setup |
| `terraform init` | Initialize with S3 backend |
| `terraform state list` | List resources |
| `terraform state show <resource>` | Show resource details |
| `terraform force-unlock <ID>` | Force unlock state |

---

## ✨ Summary

Your Terraform state is now:
- ✅ Stored remotely in S3
- ✅ Encrypted at rest
- ✅ Versioned for recovery
- ✅ Locked to prevent conflicts
- ✅ Shareable with team members

Ready for production deployment! 🚀


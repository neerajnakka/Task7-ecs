# ============================================================================
# S3 BACKEND SETUP SCRIPT
# ============================================================================
# This script creates the S3 bucket and DynamoDB table for Terraform state
# Usage: .\setup-s3-backend.ps1

param(
    [string]$BucketName = "neeraj-strapi-task10-state",
    [string]$Region = "ap-south-1",
    [string]$Profile = "neerajnakka.n@gmail.com",
    [string]$DynamoDBTable = "terraform-locks"
)

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║         TERRAFORM S3 BACKEND SETUP                           ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n📋 Configuration:" -ForegroundColor Cyan
Write-Host "  Bucket Name: $BucketName"
Write-Host "  Region: $Region"
Write-Host "  Profile: $Profile"
Write-Host "  DynamoDB Table: $DynamoDBTable"

# ============================================================================
# Step 1: Create S3 Bucket
# ============================================================================
Write-Host "`n📦 Step 1: Creating S3 Bucket..." -ForegroundColor Yellow

try {
    aws s3api create-bucket `
        --bucket $BucketName `
        --region $Region `
        --create-bucket-configuration LocationConstraint=$Region `
        --profile $Profile `
        --output text
    
    Write-Host "✅ S3 bucket created successfully" -ForegroundColor Green
} catch {
    Write-Host "⚠️  S3 bucket creation failed or already exists" -ForegroundColor Yellow
}

# ============================================================================
# Step 2: Enable Versioning
# ============================================================================
Write-Host "`n🔄 Step 2: Enabling Versioning..." -ForegroundColor Yellow

try {
    aws s3api put-bucket-versioning `
        --bucket $BucketName `
        --versioning-configuration Status=Enabled `
        --profile $Profile `
        --output text
    
    Write-Host "✅ Versioning enabled" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to enable versioning: $_" -ForegroundColor Red
}

# ============================================================================
# Step 3: Enable Encryption
# ============================================================================
Write-Host "`n🔐 Step 3: Enabling Encryption..." -ForegroundColor Yellow

try {
    $encryptionConfig = @{
        Rules = @(
            @{
                ApplyServerSideEncryptionByDefault = @{
                    SSEAlgorithm = "AES256"
                }
            }
        )
    } | ConvertTo-Json -Compress
    
    aws s3api put-bucket-encryption `
        --bucket $BucketName `
        --server-side-encryption-configuration $encryptionConfig `
        --profile $Profile `
        --output text
    
    Write-Host "✅ Encryption enabled" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to enable encryption: $_" -ForegroundColor Red
}

# ============================================================================
# Step 4: Block Public Access
# ============================================================================
Write-Host "`n🔒 Step 4: Blocking Public Access..." -ForegroundColor Yellow

try {
    aws s3api put-public-access-block `
        --bucket $BucketName `
        --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" `
        --profile $Profile `
        --output text
    
    Write-Host "✅ Public access blocked" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to block public access: $_" -ForegroundColor Red
}

# ============================================================================
# Step 5: Create DynamoDB Table for State Locking
# ============================================================================
Write-Host "`n🔐 Step 5: Creating DynamoDB Table for State Locking..." -ForegroundColor Yellow

try {
    aws dynamodb create-table `
        --table-name $DynamoDBTable `
        --attribute-definitions AttributeName=LockID,AttributeType=S `
        --key-schema AttributeName=LockID,KeyType=HASH `
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 `
        --region $Region `
        --profile $Profile `
        --output text
    
    Write-Host "✅ DynamoDB table created" -ForegroundColor Green
    
    # Wait for table to be active
    Write-Host "⏳ Waiting for table to be active..." -ForegroundColor Yellow
    aws dynamodb wait table-exists `
        --table-name $DynamoDBTable `
        --region $Region `
        --profile $Profile
    
    Write-Host "✅ DynamoDB table is active" -ForegroundColor Green
} catch {
    Write-Host "⚠️  DynamoDB table creation failed or already exists" -ForegroundColor Yellow
}

# ============================================================================
# Summary
# ============================================================================
Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║         ✅ S3 BACKEND SETUP COMPLETE                          ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n📝 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. cd task10-blue-green/terraform"
Write-Host "  2. terraform init"
Write-Host "  3. terraform plan"
Write-Host "  4. terraform apply"

Write-Host "`n💾 State File Location:" -ForegroundColor Cyan
Write-Host "  S3 Bucket: $BucketName"
Write-Host "  State File: task10-blue-green/terraform.tfstate"
Write-Host "  Region: $Region"

Write-Host "`n🔒 State Locking:" -ForegroundColor Cyan
Write-Host "  DynamoDB Table: $DynamoDBTable"
Write-Host "  Prevents concurrent modifications"

Write-Host "`n✨ Your Terraform state is now secure and shareable!`n" -ForegroundColor Green

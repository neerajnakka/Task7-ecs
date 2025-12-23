# ============================================================================
# TERRAFORM S3 BACKEND CONFIGURATION
# ============================================================================
# This stores the Terraform state in S3 instead of locally
# Benefits:
# - Team collaboration (shared state)
# - State locking (prevents concurrent modifications)
# - Backup and versioning
# - Remote access

terraform {
  backend "s3" {
    # S3 bucket name (must be globally unique)
    bucket = "neeraj-strapi-task10-state"
    
    # Path to state file within bucket
    key = "task10-blue-green/terraform.tfstate"
    
    # AWS region where bucket is located
    region = "ap-south-1"
    
    # Encrypt state file at rest
    encrypt = true
    
    # AWS profile to use for backend operations
    profile = "neerajnakka.n@gmail.com"
    
    # Note: DynamoDB state locking requires additional IAM permissions
    # If you have DynamoDB access, uncomment the line below:
    # dynamodb_table = "terraform-locks"
  }
}

# ============================================================================
# NOTES
# ============================================================================
# Before running 'terraform init', you need to:
#
# 1. Create the S3 bucket:
#    aws s3api create-bucket \
#      --bucket neeraj-strapi-task10-state \
#      --region ap-south-1 \
#      --create-bucket-configuration LocationConstraint=ap-south-1 \
#      --profile neerajnakka.n@gmail.com
#
# 2. Enable versioning on the bucket:
#    aws s3api put-bucket-versioning \
#      --bucket neeraj-strapi-task10-state \
#      --versioning-configuration Status=Enabled \
#      --profile neerajnakka.n@gmail.com
#
# 3. Enable encryption on the bucket:
#    aws s3api put-bucket-encryption \
#      --bucket neeraj-strapi-task10-state \
#      --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}' \
#      --profile neerajnakka.n@gmail.com
#
# 4. Create DynamoDB table for state locking:
#    aws dynamodb create-table \
#      --table-name terraform-locks \
#      --attribute-definitions AttributeName=LockID,AttributeType=S \
#      --key-schema AttributeName=LockID,KeyType=HASH \
#      --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
#      --region ap-south-1 \
#      --profile neerajnakka.n@gmail.com
#
# 5. Then run:
#    terraform init

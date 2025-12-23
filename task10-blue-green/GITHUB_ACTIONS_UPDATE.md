# GitHub Actions Update for Task 10 Organization Account

## 🎯 Overview
Update your GitHub Actions workflow to push Docker images to the organization account ECR instead of your default account.

## 📋 Required Changes

### 1. Update ECR Repository URL
**Old (Default Account)**:
```yaml
ECR_REPOSITORY: your-default-account-id.dkr.ecr.ap-south-1.amazonaws.com/strapi-repo
```

**New (Organization Account)**:
```yaml
ECR_REPOSITORY: 301782007642.dkr.ecr.ap-south-1.amazonaws.com/strapi-neeraj-ecs-repo
```

### 2. Update AWS Credentials
You need to add organization account credentials to GitHub Secrets:

**GitHub Repository → Settings → Secrets and Variables → Actions**

Add these secrets:
- `AWS_ACCESS_KEY_ID_ORG`: Access key for `neerajnakka.n@gmail.com` account
- `AWS_SECRET_ACCESS_KEY_ORG`: Secret key for `neerajnakka.n@gmail.com` account

### 3. Complete Updated Workflow

```yaml
name: Deploy to ECS Task 10

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  AWS_REGION: ap-south-1
  ECR_REPOSITORY: 301782007642.dkr.ecr.ap-south-1.amazonaws.com/strapi-neeraj-ecs-repo
  ECS_SERVICE: strapi-neeraj-service
  ECS_CLUSTER: strapi-neeraj-ecs-cluster
  ECS_TASK_DEFINITION: strapi-neeraj-task
  CONTAINER_NAME: strapi-neeraj-container

jobs:
  deploy:
    name: Deploy to Task 10 Organization Account
    runs-on: ubuntu-latest
    environment: production

    steps:
    - name: Checkout
      uses: actions/checkout@v3

    - name: Configure AWS credentials for Organization Account
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID_ORG }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY_ORG }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1

    - name: Build, tag, and push image to Amazon ECR
      id: build-image
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        IMAGE_TAG: ${{ github.sha }}
      run: |
        # Build a docker container and push it to ECR
        docker build -t $ECR_REPOSITORY:$IMAGE_TAG .
        docker build -t $ECR_REPOSITORY:latest .
        docker push $ECR_REPOSITORY:$IMAGE_TAG
        docker push $ECR_REPOSITORY:latest
        echo "image=$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT

    - name: Download task definition
      run: |
        aws ecs describe-task-definition \
          --task-definition $ECS_TASK_DEFINITION \
          --query taskDefinition > task-definition.json

    - name: Fill in the new image ID in the Amazon ECS task definition
      id: task-def
      uses: aws-actions/amazon-ecs-render-task-definition@v1
      with:
        task-definition: task-definition.json
        container-name: ${{ env.CONTAINER_NAME }}
        image: ${{ steps.build-image.outputs.image }}

    - name: Deploy Amazon ECS task definition
      uses: aws-actions/amazon-ecs-deploy-task-definition@v1
      with:
        task-definition: ${{ steps.task-def.outputs.task-definition }}
        service: ${{ env.ECS_SERVICE }}
        cluster: ${{ env.ECS_CLUSTER }}
        wait-for-service-stability: true
```

## 🔐 Setting Up AWS Credentials

### Option A: Create New IAM User (Recommended)
1. **AWS Console** → **IAM** → **Users** → **Create User**
2. **Username**: `github-actions-task10`
3. **Attach Policies**:
   - `AmazonEC2ContainerRegistryPowerUser`
   - `AmazonECS_FullAccess`
4. **Create Access Keys** → Copy to GitHub Secrets

### Option B: Use Existing Credentials
If you already have programmatic access for the org account:
1. Use existing access key/secret key
2. Ensure it has ECR and ECS permissions

## 📝 Step-by-Step Implementation

### Step 1: Update GitHub Secrets
1. Go to your GitHub repository
2. **Settings** → **Secrets and Variables** → **Actions**
3. Add:
   - `AWS_ACCESS_KEY_ID_ORG`
   - `AWS_SECRET_ACCESS_KEY_ORG`

### Step 2: Update Workflow File
1. Update `.github/workflows/deploy.yml` (or your workflow file)
2. Replace with the updated workflow above
3. Commit and push changes

### Step 3: Test the Workflow
1. Make a small code change
2. Push to main branch
3. Watch GitHub Actions run
4. Verify image appears in ECR: `strapi-neeraj-ecs-repo`

### Step 4: Verify Deployment
1. Check ECS service updates with new task definition
2. Verify application is accessible via ALB
3. Check CloudWatch logs for successful startup

## 🚨 Important Notes

### ECR Repository Name
- **Terraform created**: `strapi-neeraj-ecs-repo`
- **Full URI**: `301782007642.dkr.ecr.ap-south-1.amazonaws.com/strapi-neeraj-ecs-repo`

### ECS Resources Names
- **Cluster**: `strapi-neeraj-ecs-cluster`
- **Service**: `strapi-neeraj-service`
- **Task Definition**: `strapi-neeraj-task`
- **Container**: `strapi-neeraj-container` (check your task definition)

### Container Name Verification
Check your current task definition for the exact container name:
```bash
aws ecs describe-task-definition \
  --task-definition strapi-neeraj-task \
  --profile neerajnakka.n@gmail.com \
  --query 'taskDefinition.containerDefinitions[0].name'
```

## 🎯 Expected Results

After successful deployment:
1. ✅ Image pushed to org account ECR
2. ✅ ECS service updated with new task definition
3. ✅ Application accessible via ALB
4. ✅ Ready for blue/green deployments

## 🔄 Future Blue/Green Deployments

Once this is working, you can enhance the workflow to use CodeDeploy for blue/green deployments instead of direct ECS updates.

This approach maintains proper DevOps practices while working with the organization account infrastructure!
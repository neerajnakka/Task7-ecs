# GitHub Actions Workflow Setup for Task 10 Organization Account

## 📁 File Location
Place the `deploy-task10-org.yml` file in your repository at:
```
.github/workflows/deploy-task10-org.yml
```

## 🔐 Required GitHub Secrets

### Step 1: Get AWS Credentials for Organization Account
You need programmatic access credentials for the `neerajnakka.n@gmail.com` AWS account.

**Option A: Create New IAM User (Recommended)**
1. **AWS Console** → **IAM** → **Users** → **Create User**
2. **Username**: `github-actions-task10`
3. **Permissions**: Attach policies directly
   - `AmazonEC2ContainerRegistryPowerUser`
   - `AmazonECS_FullAccess`
4. **Security credentials** → **Create access key**
5. **Use case**: Application running outside AWS
6. **Copy** Access Key ID and Secret Access Key

**Option B: Use Existing Credentials**
If you already have programmatic access for the org account, use those credentials.

### Step 2: Add Secrets to GitHub Repository
1. Go to your GitHub repository
2. **Settings** → **Secrets and variables** → **Actions**
3. **New repository secret** → Add these two secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AWS_ACCESS_KEY_ID_ORG` | Your access key ID | For org account access |
| `AWS_SECRET_ACCESS_KEY_ORG` | Your secret access key | For org account access |

## 📋 Workflow Configuration Details

### Environment Variables
```yaml
AWS_REGION: ap-south-1                    # Your AWS region
ECR_REPOSITORY: strapi-neeraj-ecs-repo    # ECR repo name (without registry URL)
ECR_REGISTRY: 301782007642.dkr.ecr.ap-south-1.amazonaws.com  # Your org account ECR
ECS_SERVICE: strapi-neeraj-service        # ECS service name
ECS_CLUSTER: strapi-neeraj-ecs-cluster    # ECS cluster name
ECS_TASK_DEFINITION: strapi-neeraj-task   # Task definition family name
CONTAINER_NAME: strapi-neeraj-container   # Container name in task definition
```

### Trigger Events
The workflow runs on:
- **Push** to `main` or `task10` branches
- **Pull request** to `main` or `task10` branches  
- **Manual trigger** (workflow_dispatch)

## 🚀 How to Use

### Method 1: Automatic Trigger
1. Make changes to your code
2. Commit and push to `main` branch:
   ```bash
   git add .
   git commit -m "Deploy to Task 10 org account"
   git push origin main
   ```
3. GitHub Actions will automatically run

### Method 2: Manual Trigger
1. Go to your GitHub repository
2. **Actions** tab
3. **Deploy to ECS Task 10 - Organization Account**
4. **Run workflow** → **Run workflow**

## 📊 Workflow Steps Explained

### 1. **Checkout Code**
Downloads your repository code to the runner

### 2. **Configure AWS Credentials**
Sets up AWS CLI with organization account credentials

### 3. **Login to ECR**
Authenticates Docker with your organization's ECR registry

### 4. **Build and Push Image**
- Builds Docker image from your Dockerfile
- Tags with commit SHA and 'latest'
- Pushes both tags to ECR

### 5. **Download Task Definition**
Gets current ECS task definition from AWS

### 6. **Update Task Definition**
Updates the task definition with new image URI

### 7. **Deploy to ECS**
- Updates ECS service with new task definition
- Waits for deployment to complete
- Ensures service stability

### 8. **Verify Deployment**
Checks service status and provides application URLs

## 🔍 Monitoring the Deployment

### GitHub Actions Logs
- Go to **Actions** tab in your repository
- Click on the running/completed workflow
- View detailed logs for each step

### AWS Console Verification
1. **ECR**: Check if new image was pushed
2. **ECS**: Verify service is updating/updated
3. **Application**: Test the ALB URL

## 🚨 Troubleshooting

### Common Issues

**❌ Authentication Error**
```
Error: Could not assume role with OIDC
```
**Solution**: Check GitHub secrets are correctly set

**❌ ECR Push Failed**
```
Error: denied: User is not authorized to perform: ecr:BatchCheckLayerAvailability
```
**Solution**: Ensure IAM user has ECR permissions

**❌ ECS Deployment Failed**
```
Error: Service was unable to place a task
```
**Solution**: Check ECS service configuration and resource limits

**❌ Container Name Not Found**
```
Error: Could not find container definition with name: strapi-neeraj-container
```
**Solution**: Verify container name in your task definition

### Verify Container Name
Run this command to check your actual container name:
```bash
aws ecs describe-task-definition \
  --task-definition strapi-neeraj-task \
  --profile neerajnakka.n@gmail.com \
  --query 'taskDefinition.containerDefinitions[0].name'
```

## ✅ Expected Results

After successful deployment:
1. ✅ New Docker image in ECR with commit SHA tag
2. ✅ ECS service updated with new task definition
3. ✅ Application accessible at: `http://strapi-neeraj-alb-1558623704.ap-south-1.elb.amazonaws.com`
4. ✅ Admin panel at: `http://strapi-neeraj-alb-1558623704.ap-south-1.elb.amazonaws.com/admin`
5. ✅ Ready for blue/green deployments via CodeDeploy

## 🔄 Next Steps

Once this basic deployment works:
1. **Test the application** via ALB URL
2. **Verify blue/green infrastructure** is ready
3. **Enhance workflow** to use CodeDeploy for blue/green deployments
4. **Set up monitoring** and alerting

This workflow provides a solid foundation for deploying to your Task 10 organization account infrastructure!
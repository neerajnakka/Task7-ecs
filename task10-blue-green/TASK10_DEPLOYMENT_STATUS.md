# Task 10 - Blue/Green Deployment Infrastructure - Deployment Status

## Current Status: IN PROGRESS ✅

Your Strapi Blue/Green deployment infrastructure is being deployed with unique naming to avoid conflicts in the shared AWS account.

---

## Key Changes Made

### 1. **Unique Resource Naming (Neeraj Suffix)**
All resources now include "neeraj" in their names to prevent conflicts with other team members:
- ✅ VPC: `strapi-neeraj-vpc`
- ✅ ECS Cluster: `strapi-neeraj-ecs-cluster`
- ✅ ALB: `strapi-neeraj-alb`
- ✅ Target Groups: `strapi-neeraj-blue-tg`, `strapi-neeraj-green-tg`
- ✅ RDS: `strapi-neeraj-db`
- ✅ IAM Roles: `strapi-neeraj-ecs-execution-role`, `strapi-neeraj-ecs-task-role`, `strapi-neeraj-codedeploy-role`
- ✅ CodeDeploy: `strapi-neeraj-app`, `strapi-neeraj-deployment-group`
- ✅ CloudWatch: `strapi-neeraj-health-dashboard`, `strapi-neeraj-cpu-high`, `strapi-neeraj-memory-high`

### 2. **VPC CIDR Updated**
Changed from `10.0.0.0/16` to `10.1.0.0/16` to avoid conflicts with existing infrastructure.

### 3. **PostgreSQL Version Fixed**
Updated from `16.3` (not available) to `15.4` (supported in free tier).

### 4. **CodeDeploy Load Balancer Info Added**
Added required `load_balancer_info` block to CodeDeploy deployment group for ECS Blue/Green deployments.

---

## Resources Being Created

### Networking (7 resources)
- VPC (10.1.0.0/16)
- 2 Public Subnets
- 2 Private Subnets
- Internet Gateway
- Route Table
- 2 Route Table Associations

### Load Balancing (4 resources)
- Application Load Balancer
- Blue Target Group
- Green Target Group
- HTTP Listener (with weighted routing)

### Security (3 resources)
- ALB Security Group
- ECS Security Group
- RDS Security Group

### Container Orchestration (4 resources)
- ECS Cluster
- ECS Capacity Providers
- ECS Task Definition
- ECS Service (with CODE_DEPLOY controller)

### Container Registry (2 resources)
- ECR Repository
- ECR Lifecycle Policy

### Deployment Automation (2 resources)
- CodeDeploy Application
- CodeDeploy Deployment Group (Canary 10% for 5 minutes)

### Database (2 resources)
- RDS PostgreSQL (15.4, db.t3.micro)
- DB Subnet Group

### Monitoring (4 resources)
- CloudWatch Log Group
- CloudWatch Dashboard
- CPU Utilization Alarm
- Memory Utilization Alarm

### IAM (6 resources)
- ECS Execution Role
- ECS Task Role
- CodeDeploy Role
- ECS Task Policy
- CodeDeploy Custom Policy
- Policy Attachments

**Total: 37 resources**

---

## Why "Neeraj" Suffix?

Since this is a shared AWS account with multiple team members:
- ✅ Prevents accidental deletion of other employees' infrastructure
- ✅ Prevents other employees from accidentally deleting your infrastructure
- ✅ Makes it clear who created and owns each resource
- ✅ Allows multiple team members to run the same Terraform code without conflicts
- ✅ Follows AWS best practices for multi-tenant environments

---

## Deployment Architecture

```
Internet (0.0.0.0/0)
    ↓
ALB (strapi-neeraj-alb)
    ↓
┌─────────────────────────────────┐
│  Listener (Port 80)             │
│  Weighted Routing:              │
│  - Blue: 100% (initially)       │
│  - Green: 0% (initially)        │
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│  ECS Service                    │
│  (CODE_DEPLOY Controller)       │
│  - Blue Tasks (Current)         │
│  - Green Tasks (New)            │
└─────────────────────────────────┘
    ↓
RDS PostgreSQL (strapi-neeraj-db)
```

---

## Blue/Green Deployment Flow

1. **Initial State**: Blue receives 100% traffic, Green is empty
2. **New Deployment**: CodeDeploy creates Green tasks with new version
3. **Canary Phase**: 10% traffic → Green for 5 minutes
4. **Health Check**: If Green is healthy, proceed
5. **Full Shift**: 100% traffic → Green
6. **Cleanup**: Blue tasks terminated after 5 minutes
7. **Rollback**: If Green fails, automatically rollback to Blue

---

## Next Steps

1. **Wait for deployment to complete** (currently in progress)
2. **Verify all resources created**:
   ```bash
   terraform output
   ```

3. **Build and push Docker image**:
   ```bash
   docker build -t strapi-app:latest .
   docker tag strapi-app:latest 301782007642.dkr.ecr.ap-south-1.amazonaws.com/strapi-neeraj-ecs-repo:latest
   aws ecr get-login-password --region ap-south-1 --profile neerajnakka.n@gmail.com | docker login --username AWS --password-stdin 301782007642.dkr.ecr.ap-south-1.amazonaws.com
   docker push 301782007642.dkr.ecr.ap-south-1.amazonaws.com/strapi-neeraj-ecs-repo:latest
   ```

4. **Register new task definition** with ECR image

5. **Create CodeDeploy deployment** to trigger Blue/Green deployment

6. **Monitor deployment** via CloudWatch dashboard

---

## Important Notes

- **All resources are tagged** with "Name" tag for easy identification
- **State is stored in S3** (`neeraj-strapi-task10-state`) with encryption
- **Automatic rollback enabled** on deployment failure
- **Container Insights enabled** for detailed monitoring
- **Health checks configured** on target groups (2 healthy, 3 unhealthy threshold)

---

## Troubleshooting

If deployment fails:
1. Check CloudWatch logs: `/ecs/strapi-neeraj-app`
2. Check ECS service events in AWS Console
3. Verify security group rules
4. Check RDS connectivity
5. Review CodeDeploy deployment logs

---

## Cost Estimation

**Monthly Cost (Approximate):**
- ECS Fargate: $0 (750 hours free tier)
- ALB: $0 (750 hours free tier)
- RDS: $0 (db.t3.micro free tier)
- ECR: $0 (500MB free tier)
- CloudWatch: ~$5 (logs + alarms)
- **Total: ~$5/month**

---

## Deployment Timeline

- **Started**: December 23, 2025
- **Status**: In Progress
- **Expected Completion**: Within 10-15 minutes

---

**Created by**: Neeraj  
**Account**: 301782007642 (neerajnakka.n@gmail.com)  
**Region**: ap-south-1 (Mumbai)  
**Backend**: S3 (neeraj-strapi-task10-state)

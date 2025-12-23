# Task 10 - Blue/Green Deployment Infrastructure ✅ DEPLOYED

## Deployment Status: SUCCESS

Your Strapi Blue/Green deployment infrastructure has been successfully deployed to AWS!

---

## 📊 Infrastructure Summary

### Resources Created: 37

**Networking:**
- ✅ VPC (10.0.0.0/16)
- ✅ 2 Public Subnets (ap-south-1a, ap-south-1b)
- ✅ 2 Private Subnets (ap-south-1a, ap-south-1b)
- ✅ Internet Gateway
- ✅ Route Table (Public)
- ✅ Route Table Associations

**Load Balancing:**
- ✅ Application Load Balancer (ALB)
- ✅ Blue Target Group (strapi-blue-tg)
- ✅ Green Target Group (strapi-green-tg)
- ✅ HTTP Listener with weighted traffic routing

**Security:**
- ✅ ALB Security Group (HTTP 80, HTTPS 443)
- ✅ ECS Security Group (Port 1337)
- ✅ RDS Security Group (Port 5432)

**Container Orchestration:**
- ✅ ECS Cluster (strapi-ecs-cluster)
- ✅ ECS Service (strapi-service) with CODE_DEPLOY controller
- ✅ ECS Task Definition (strapi-task)
- ✅ Capacity Providers (FARGATE)

**Container Registry:**
- ✅ ECR Repository (strapi-ecs-repo)
- ✅ ECR Lifecycle Policy (keeps last 10 images)

**Deployment Automation:**
- ✅ CodeDeploy Application (strapi-app)
- ✅ CodeDeploy Deployment Group (strapi-deployment-group)
- ✅ Deployment Strategy: Canary 10% for 5 minutes
- ✅ Automatic Rollback on Failure

**Database:**
- ✅ RDS PostgreSQL (db.t3.micro, 20GB)
- ✅ DB Subnet Group
- ✅ Automated Backups (1 day retention)

**Monitoring:**
- ✅ CloudWatch Log Group (/ecs/strapi-app)
- ✅ CloudWatch Dashboard (strapi-health-dashboard)
- ✅ CPU Utilization Alarm (>80%)
- ✅ Memory Utilization Alarm (>80%)

**IAM Roles & Policies:**
- ✅ ECS Execution Role
- ✅ ECS Task Role
- ✅ CodeDeploy Role
- ✅ Custom IAM Policies for S3, Secrets Manager, CloudWatch

---

## 🌐 Access Points

### Application URLs:
```
Application: http://strapi-alb-793585438.ap-south-1.elb.amazonaws.com
Admin Panel: http://strapi-alb-793585438.ap-south-1.elb.amazonaws.com/admin
```

### AWS Console Links:
```
CloudWatch Dashboard: https://console.aws.amazon.com/cloudwatch/home?region=ap-south-1#dashboards:name=strapi-health-dashboard
ECS Cluster: https://console.aws.amazon.com/ecs/v2/clusters/strapi-ecs-cluster
ECR Repository: https://console.aws.amazon.com/ecr/repositories/strapi-ecs-repo
CodeDeploy: https://console.aws.amazon.com/codesuite/codedeploy/applications/strapi-app
RDS Database: https://console.aws.amazon.com/rds/v2/databases/strapi-db
```

---

## 🔧 Key Configuration Details

### ECS Service Configuration:
- **Launch Type:** Fargate
- **Desired Count:** 1 task
- **Deployment Controller:** CODE_DEPLOY (for Blue/Green)
- **Load Balancers:** Both Blue and Green target groups attached
- **Network:** Public subnets with auto-assigned public IPs

### Blue/Green Deployment Strategy:
- **Type:** Canary 10% for 5 minutes
- **Traffic Control:** WITH_TRAFFIC_CONTROL
- **Automatic Rollback:** Enabled on deployment failure
- **Termination:** Old tasks terminated after successful deployment

### Database Configuration:
- **Engine:** PostgreSQL 16.3
- **Instance Class:** db.t3.micro (free tier)
- **Storage:** 20GB (gp3)
- **Backup Retention:** 1 day (free tier limit)
- **Database Name:** strapi_ecs_db
- **Username:** strapi
- **Password:** Stored in AWS Secrets Manager

### State Management:
- **Backend:** S3 (neeraj-strapi-task10-state)
- **State File:** task10-blue-green/terraform.tfstate
- **Encryption:** AES256
- **Versioning:** Enabled
- **Region:** ap-south-1

---

## 📋 Next Steps

### 1. Build and Push Docker Image
```bash
# Build Strapi Docker image
docker build -t strapi-app:latest .

# Tag for ECR
docker tag strapi-app:latest 301782007642.dkr.ecr.ap-south-1.amazonaws.com/strapi-ecs-repo:latest

# Login to ECR
aws ecr get-login-password --region ap-south-1 --profile neerajnakka.n@gmail.com | docker login --username AWS --password-stdin 301782007642.dkr.ecr.ap-south-1.amazonaws.com

# Push to ECR
docker push 301782007642.dkr.ecr.ap-south-1.amazonaws.com/strapi-ecs-repo:latest
```

### 2. Update ECS Task Definition
```bash
# Register new task definition with ECR image
aws ecs register-task-definition \
  --family strapi-task \
  --container-definitions file://task-definition.json \
  --region ap-south-1 \
  --profile neerajnakka.n@gmail.com
```

### 3. Create CodeDeploy Deployment
```bash
# Create appspec.yaml for CodeDeploy
# Then create deployment via AWS Console or CLI
```

### 4. Monitor Deployment
- Check CloudWatch Dashboard for metrics
- View ECS service events
- Monitor CodeDeploy deployment progress
- Check CloudWatch Logs for application logs

---

## 🔐 Security Notes

✅ **Encryption:** State file encrypted in S3  
✅ **Network:** Private subnets for RDS, public for ALB  
✅ **Security Groups:** Restrictive ingress rules  
✅ **IAM:** Least privilege roles and policies  
✅ **Secrets:** Database password in Secrets Manager  

---

## 💰 Cost Estimation (Monthly)

| Service | Tier | Cost |
|---------|------|------|
| ECS Fargate | 750 hours free | $0 |
| ALB | 750 hours free | $0 |
| RDS | db.t3.micro free | $0 |
| ECR | 500MB free | $0 |
| CloudWatch | Logs + Alarms | ~$5 |
| Data Transfer | 1GB free | $0 |
| **Total** | | **~$5/month** |

*Note: Free tier limits apply. Costs increase after free tier usage.*

---

## 📚 Learning Resources

### Blue/Green Deployment:
- [AWS Blue/Green Deployment](https://docs.aws.amazon.com/whitepapers/latest/blue-green-deployments/welcome.html)
- [CodeDeploy Blue/Green](https://docs.aws.amazon.com/codedeploy/latest/userguide/deployments-create-blue-green.html)

### ECS & Fargate:
- [ECS Task Definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html)
- [Fargate Launch Type](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_types.html)

### Terraform:
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform State Management](https://www.terraform.io/language/state)

---

## ✨ What You've Learned

✅ Blue/Green deployment strategy  
✅ ECS cluster and service configuration  
✅ ALB with weighted target groups  
✅ CodeDeploy for automated deployments  
✅ Canary deployment strategy  
✅ Automatic rollback mechanisms  
✅ IAM roles and policies  
✅ Terraform infrastructure as code  
✅ S3 backend for state management  
✅ CloudWatch monitoring and alarms  

---

## 🎯 Deployment Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Internet (0.0.0.0/0)                 │
└────────────────────────┬────────────────────────────────┘
                         │
                    ┌────▼────┐
                    │   ALB    │ (Port 80, 443)
                    └────┬────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   ┌────▼────┐      ┌────▼────┐      ┌────▼────┐
   │  Blue   │      │ Green   │      │ Listener│
   │   TG    │      │   TG    │      │ Rules   │
   │ (0%)    │      │ (100%)  │      │         │
   └────┬────┘      └────┬────┘      └─────────┘
        │                │
   ┌────▼────────────────▼────┐
   │   ECS Service            │
   │ (CODE_DEPLOY Controller) │
   └────┬─────────────────────┘
        │
   ┌────▼────────────────────┐
   │  ECS Task (Fargate)     │
   │  - Strapi Container     │
   │  - Port 1337            │
   └────┬─────────────────────┘
        │
   ┌────▼────────────────────┐
   │  RDS PostgreSQL         │
   │  - Port 5432            │
   │  - strapi_ecs_db        │
   └─────────────────────────┘
```

---

## 🚀 You're Ready!

Your infrastructure is now ready for:
1. Building and pushing Docker images
2. Deploying Strapi to ECS
3. Managing Blue/Green deployments
4. Monitoring application health
5. Scaling and managing traffic

**Next:** Build your Strapi Docker image and push it to ECR!

---

**Deployed:** December 23, 2025  
**Region:** ap-south-1 (Mumbai)  
**Account:** 301782007642  
**Profile:** neerajnakka.n@gmail.com

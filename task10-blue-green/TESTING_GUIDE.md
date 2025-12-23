# Task 10 Blue/Green Deployment Testing Guide

This guide walks you through testing the complete Blue/Green deployment setup in the AWS console.

## 🎯 Testing Overview

We'll test the following components:
1. **Application Access** - Verify Strapi is running
2. **ECS Service** - Check container health
3. **Load Balancer** - Verify traffic routing
4. **CodeDeploy** - Test blue/green deployments
5. **Monitoring** - Check CloudWatch metrics
6. **Database** - Verify RDS connectivity

---

## 📋 Prerequisites

- AWS Console access with `neerajnakka.n@gmail.com` profile
- Application URL: `http://strapi-neeraj-alb-1558623704.ap-south-1.elb.amazonaws.com`
- Admin Panel: `http://strapi-neeraj-alb-1558623704.ap-south-1.elb.amazonaws.com/admin`

---

## 🔍 Step 1: Test Application Access

### 1.1 Access the Application
1. Open browser and go to: `http://strapi-neeraj-alb-1558623704.ap-south-1.elb.amazonaws.com`
2. **Expected Result**: You should see Strapi welcome page or API response
3. **If it fails**: Check ECS service status (Step 2)

### 1.2 Access Admin Panel
1. Go to: `http://strapi-neeraj-alb-1558623704.ap-south-1.elb.amazonaws.com/admin`
2. **Expected Result**: Strapi admin login page
3. **If it fails**: Check application logs in CloudWatch (Step 5)

---

## 🐳 Step 2: Verify ECS Service Health

### 2.1 Check ECS Cluster
1. **AWS Console** → **ECS** → **Clusters**
2. Click on **`strapi-neeraj-ecs-cluster`**
3. **Verify**:
   - Status: `ACTIVE`
   - Running tasks: `1`
   - Capacity providers: `FARGATE`

### 2.2 Check ECS Service
1. In the cluster, click **Services** tab
2. Click on **`strapi-neeraj-service`**
3. **Verify**:
   - Status: `ACTIVE`
   - Running count: `1/1`
   - Health check: `HEALTHY`

### 2.3 Check Task Details
1. Click **Tasks** tab
2. Click on the running task
3. **Verify**:
   - Last status: `RUNNING`
   - Health status: `HEALTHY`
   - CPU/Memory utilization: Normal levels

### 2.4 Check Container Logs
1. In task details, click **Logs** tab
2. **Look for**:
   - Strapi startup messages
   - Database connection success
   - No error messages

---

## ⚖️ Step 3: Verify Load Balancer Configuration

### 3.1 Check Application Load Balancer
1. **AWS Console** → **EC2** → **Load Balancers**
2. Click on **`strapi-neeraj-alb`**
3. **Verify**:
   - State: `active`
   - Scheme: `internet-facing`
   - DNS name matches your application URL

### 3.2 Check Target Groups
1. **AWS Console** → **EC2** → **Target Groups**
2. **Blue Target Group** (`strapi-neeraj-blue-tg`):
   - Status: `healthy`
   - Registered targets: 1 (your ECS task)
   - Health check: Passing
3. **Green Target Group** (`strapi-neeraj-green-tg`):
   - Status: `unused` (no targets registered yet)
   - This is normal - green is used during deployments

### 3.3 Check Listener Rules
1. In Load Balancer details, click **Listeners** tab
2. Click on **HTTP:80** listener
3. **Verify**:
   - Default action forwards to `strapi-neeraj-blue-tg`
   - Rule priority and conditions are correct

---

## 🚀 Step 4: Test CodeDeploy Blue/Green Deployment

### 4.1 Check CodeDeploy Application
1. **AWS Console** → **CodeDeploy** → **Applications**
2. Click on **`strapi-neeraj-app`**
3. **Verify**:
   - Compute platform: `ECS`
   - Status: `Active`

### 4.2 Check Deployment Group
1. In the application, click **Deployment groups** tab
2. Click on **`strapi-neeraj-deployment-group`**
3. **Verify Configuration**:
   - Service role: `strapi-neeraj-codedeploy-role`
   - ECS cluster: `strapi-neeraj-ecs-cluster`
   - ECS service: `strapi-neeraj-service`
   - Load balancer: `strapi-neeraj-alb`
   - Deployment config: `CodeDeployDefault.ECSCanary10Percent5Minutes`

### 4.3 Simulate a Blue/Green Deployment (Optional)
**⚠️ Note**: This requires creating a new task definition. For now, just verify the setup.

1. In deployment group, click **Create deployment**
2. **You should see**:
   - Application name: `strapi-neeraj-app`
   - Deployment group: `strapi-neeraj-deployment-group`
   - Revision type options
3. **Don't create** the deployment yet (we need a new task definition first)

---

## 📊 Step 5: Verify CloudWatch Monitoring

### 5.1 Check CloudWatch Dashboard
1. **AWS Console** → **CloudWatch** → **Dashboards**
2. Click on **`strapi-neeraj-health-dashboard`**
3. **Verify Widgets**:
   - CPU Utilization graph
   - Memory Utilization graph
   - ALB Request Count
   - ALB Response Time

### 5.2 Check CloudWatch Alarms
1. **AWS Console** → **CloudWatch** → **Alarms**
2. **Find these alarms**:
   - `strapi-neeraj-cpu-high`: Should be in `OK` state
   - `strapi-neeraj-memory-high`: Should be in `OK` state
3. **If alarms are in ALARM state**: Check ECS task performance

### 5.3 Check Application Logs
1. **AWS Console** → **CloudWatch** → **Log groups**
2. Click on **`/ecs/strapi-neeraj-app`**
3. Click on the latest log stream
4. **Look for**:
   - Strapi startup logs
   - Database connection logs
   - HTTP request logs
   - Any error messages

---

## 🗄️ Step 6: Verify RDS Database

### 6.1 Check RDS Instance
1. **AWS Console** → **RDS** → **Databases**
2. Click on **`strapi-neeraj-db`**
3. **Verify**:
   - Status: `Available`
   - Engine: `postgres 15.10`
   - Multi-AZ: `No` (single AZ for cost)
   - Storage: `20 GB`

### 6.2 Check Database Connectivity
1. In RDS details, note the **Endpoint**
2. **Security Groups**: Should allow connections from ECS security group
3. **Subnet Group**: Should be in private subnets
4. **Publicly accessible**: Should be `No`

### 6.3 Verify Database Connection from Application
1. Check application logs in CloudWatch
2. **Look for**:
   - Database connection success messages
   - No database connection errors
   - Strapi database initialization logs

---

## 🔐 Step 7: Verify IAM Roles and Permissions

### 7.1 Check ECS Task Execution Role
1. **AWS Console** → **IAM** → **Roles**
2. Click on **`strapi-neeraj-ecs-execution-role`**
3. **Verify Policies**:
   - `AmazonECSTaskExecutionRolePolicy` (AWS managed)
   - Custom policy for ECR and CloudWatch

### 7.2 Check ECS Task Role
1. Click on **`strapi-neeraj-ecs-task-role`**
2. **Verify Policies**:
   - Custom policy for application-specific permissions

### 7.3 Check CodeDeploy Role
1. Click on **`strapi-neeraj-codedeploy-role`**
2. **Verify Policies**:
   - `AWSCodeDeployRoleForECS` (AWS managed)
   - Custom policy for ECS and ALB permissions

---

## 📦 Step 8: Verify ECR Repository

### 8.1 Check ECR Repository
1. **AWS Console** → **ECR** → **Repositories**
2. Click on **`strapi-neeraj-ecs-repo`**
3. **Verify**:
   - Repository exists
   - Lifecycle policy is configured
   - Image scan on push: Enabled

### 8.2 Check Container Images
1. **Current State**: Repository might be empty (no images pushed yet)
2. **For deployment testing**: You'll need to push a Docker image here
3. **URI**: `301782007642.dkr.ecr.ap-south-1.amazonaws.com/strapi-neeraj-ecs-repo`

---

## 🌐 Step 9: Verify Network Configuration

### 9.1 Check VPC
1. **AWS Console** → **VPC** → **Your VPCs**
2. Click on **`strapi-neeraj-vpc`**
3. **Verify**:
   - CIDR: `10.1.0.0/16`
   - DNS hostnames: Enabled
   - DNS resolution: Enabled

### 9.2 Check Subnets
1. **VPC** → **Subnets**
2. **Public Subnets** (for ALB):
   - `strapi-neeraj-public-subnet-1`: `10.1.0.0/24`
   - `strapi-neeraj-public-subnet-2`: `10.1.1.0/24`
3. **Private Subnets** (for RDS):
   - `strapi-neeraj-private-subnet-1`: `10.1.10.0/24`
   - `strapi-neeraj-private-subnet-2`: `10.1.11.0/24`

### 9.3 Check Security Groups
1. **EC2** → **Security Groups**
2. **ALB Security Group** (`strapi-neeraj-alb-sg`):
   - Inbound: HTTP (80) from anywhere
   - Outbound: All traffic
3. **ECS Security Group** (`strapi-neeraj-ecs-sg`):
   - Inbound: Port 1337 from ALB security group
   - Outbound: All traffic
4. **RDS Security Group** (`strapi-neeraj-rds-sg`):
   - Inbound: Port 5432 from ECS security group
   - Outbound: All traffic

---

## ✅ Expected Test Results Summary

| Component | Expected Status | What to Check |
|-----------|----------------|---------------|
| **Application** | ✅ Accessible | HTTP 200 response |
| **ECS Service** | ✅ Running | 1/1 tasks healthy |
| **Load Balancer** | ✅ Active | Targets healthy |
| **CodeDeploy** | ✅ Ready | Deployment group configured |
| **CloudWatch** | ✅ Monitoring | Metrics flowing, alarms OK |
| **RDS** | ✅ Available | Database accessible |
| **ECR** | ✅ Ready | Repository exists |
| **Network** | ✅ Configured | Security groups allow traffic |

---

## 🚨 Troubleshooting Common Issues

### Application Not Accessible
1. **Check ECS service**: Ensure tasks are running and healthy
2. **Check security groups**: Verify ALB can reach ECS tasks
3. **Check target group health**: Ensure targets are registered and healthy

### ECS Tasks Failing
1. **Check task logs**: Look for startup errors in CloudWatch
2. **Check task definition**: Verify environment variables and resource limits
3. **Check IAM permissions**: Ensure execution role has required permissions

### Database Connection Issues
1. **Check RDS status**: Ensure database is available
2. **Check security groups**: Verify ECS can reach RDS
3. **Check connection string**: Verify database endpoint and credentials

### CodeDeploy Issues
1. **Check IAM role**: Ensure CodeDeploy role has required permissions
2. **Check service configuration**: Verify ECS service and load balancer settings
3. **Check deployment configuration**: Ensure blue/green settings are correct

---

## 🎯 Next Steps for Full Blue/Green Testing

To test an actual blue/green deployment:

1. **Build and push a new Docker image** to ECR
2. **Create a new ECS task definition** with the new image
3. **Create a CodeDeploy deployment** using the new task definition
4. **Monitor the deployment** as it shifts traffic from blue to green
5. **Verify zero downtime** during the deployment process

This completes the comprehensive testing of your Task 10 Blue/Green deployment infrastructure!
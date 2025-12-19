# Task 7: Deploying Strapi on AWS ECS Fargate

This guide covers the complete setup for deploying a containerized Strapi application on serverless AWS ECS Fargate with an RDS Postgres database.

## 📂 1. Directory Structure
Create a new folder `task7-ecs` and a subfolder `terraform` inside it.
```text
neeraj-strapi-task1/
├── .github/
│   └── workflows/
│       └── deploy-ecs.yml   <-- CI/CD Pipeline
└── task7-ecs/
    └── terraform/           <-- Infrastructure Code
        ├── provider.tf
        ├── variables.tf
        ├── networking.tf
        ├── rds.tf
        ├── alb.tf
        ├── ecr.tf
        └── ecs.tf
```

---

## 🛠️ 2. Infrastructure as Code (Terraform)

### A. Provider Setup (`task7-ecs/terraform/provider.tf`)
Configures Terraform to talk to AWS.
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "neeraj1" # Your AWS CLI Profile
}
```

### B. Variables (`task7-ecs/terraform/variables.tf`)
Defines reusable values.
```hcl
variable "aws_region" {
  default = "ap-south-1"
}

variable "db_password" {
  description = "Password for RDS"
  type        = string
  sensitive   = true
}
```

### C. Networking (`task7-ecs/terraform/networking.tf`)
Creates a VPC, Public/Private Subnets, and an Internet Gateway.
```hcl
# 1. VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "strapi-ecs-vpc" }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "strapi-igw" }
}

# 3. Public Subnets (For ALB)
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "strapi-public-subnet-${count.index + 1}" }
}

# 4. Private Subnets (For ECS/RDS)
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "strapi-private-subnet-${count.index + 1}" }
}

# 5. Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "strapi-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
```

### D. Security Groups (`task7-ecs/terraform/networking.tf` continued)
Firewalls for our resources.
```hcl
# ALB SG: Open to World (HTTP)
resource "aws_security_group" "alb_sg" {
  name   = "strapi-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS SG: Only allow from ALB
resource "aws_security_group" "ecs_sg" {
  name   = "strapi-ecs-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### E. ECR Repository (`task7-ecs/terraform/ecr.tf`)
Where we store Docker images.
```hcl
resource "aws_ecr_repository" "app_repo" {
  name                 = "neeraj-strapi-ecs-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
```

### F. Load Balancer (`task7-ecs/terraform/alb.tf`)
Distributes traffic to containers.
```hcl
resource "aws_lb" "main" {
  name               = "strapi-ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "app_tg" {
  name        = "strapi-target-group"
  port        = 1337
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    matcher             = "200-304"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
```

### G. Database (`task7-ecs/terraform/rds.tf`)
Postgres Database.
```hcl
resource "aws_db_subnet_group" "default" {
  name       = "strapi-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "default" {
  allocated_storage       = 20
  db_name                 = "strapi_ecs_db"
  engine                  = "postgres"
  engine_version          = "16.3"
  instance_class          = "db.t3.micro"
  username                = "strapi"
  password                = var.db_password
  parameter_group_name    = "default.postgres16"
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  publicly_accessible     = false
}
```

### H. ECS Cluster & Service (`task7-ecs/terraform/ecs.tf`)
The core logic running the app.
```hcl
# 1. Cluster
resource "aws_ecs_cluster" "main" {
  name = "strapi-ecs-cluster"
  
  setting {
    name  = "containerInsights" # Added in Task 8, but good to have
    value = "enabled"
  }
}

# 2. Task Definition (The Blueprint)
resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024" # 1 vCPU
  memory                   = "2048" # 2 GB RAM
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "strapi-app"
      image     = "${aws_ecr_repository.app_repo.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "DATABASE_HOST", value = aws_db_instance.default.address },
        { name = "DATABASE_PORT", value = "5432" },
        { name = "DATABASE_NAME", value = "strapi_ecs_db" },
        { name = "DATABASE_USERNAME", value = "strapi" },
        { name = "DATABASE_PASSWORD", value = var.db_password },
        { name = "NODE_ENV", value = "production" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/strapi-app"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# 3. Logs
resource "aws_cloudwatch_log_group" "strapi_logs" {
  name              = "/ecs/strapi-app"
  retention_in_days = 7
}

# 4. Service (Runs the Task)
resource "aws_ecs_service" "strapi" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id # Using public subnets for simpler internet access
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "strapi-app"
    container_port   = 1337
  }
}
```

---

## 🚀 3. CI/CD (GitHub Actions)

### File: `.github/workflows/deploy-ecs.yml`
Automates building Docker image and updating ECS.

```yaml
name: Deploy Strapi to ECS

on:
  push:
    branches: [ "main" ] # Triggers on push to main
    paths:
      - 'task7-ecs/**'   # Only run if code in this folder changes

env:
  AWS_REGION: ap-south-1
  ECR_REPOSITORY: neeraj-strapi-ecs-repo
  ECS_SERVICE: strapi-service
  ECS_CLUSTER: strapi-ecs-cluster
  ECS_TASK_DEFINITION: task7-ecs/terraform/task-definition.json # (Optional if defining in Terraform only)
  CONTAINER_NAME: strapi-app

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
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
          # Build a docker container and
          # push it to ECR so that it can
          # be deployed to ECS.
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG -f Dockerfile .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          echo "image=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT

      - name: Download Task Definition
        run: |
          aws ecs describe-task-definition --task-definition strapi-task --query taskDefinition > task-definition.json

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

---

## 🏃 4. Execution Steps

### 1. Initialize Terraform
Go to the terraform directory:
```bash
cd task7-ecs/terraform
terraform init
```

### 2. Create Infrastructure
Apply the code to create VPC, DB, Cluster, etc.
```bash
terraform apply -var="db_password=YourStrongPassword123!"
```
*   Type `yes` when asked.
*   **Result**: You will see an `alb_dns_name` output (e.g., `strapi-ecs-alb-123.ap-south-1.elb.amazonaws.com`).

### 3. Trigger Deployment
Terraform creates the infrastructure, but the ECR repo is empty. You need Git Actions to fill it.
```bash
git add .
git commit -m "Setup ECS infrastructure"
git push origin main
```
*   Go to GitHub -> Actions.
*   Watch "Deploy Strapi to ECS" workflow.

### 4. Verify
Visit the ALB URL in your browser. You should see the Strapi Welcome page.

# Task 8: CloudWatch Observability & Monitoring

This task builds upon Task 7 by adding "Eyes and Ears" to our infrastructure. We implement Logging, Metrics, Alarms, and a Dashboard.

## 📂 1. Files Overview

We worked in `task7-ecs/terraform`.

| File | Status | Description |
| :--- | :--- | :--- |
| `monitoring.tf` | **NEW** | Defines CloudWatch Alarms and the Dashboard. |
| `ecs.tf` | **MODIFIED** | Updated the Cluster to enable `containerInsights`. |

---

## 🛠️ 2. The Code Changes

### A. Modified `ecs.tf` (Enable Metrics)
In Task 7, we created the ECS Cluster. In Task 8, we **modified** it to add the `setting` block for Container Insights.

**File:** `task7-ecs/terraform/ecs.tf`
```hcl
# 1. Cluster (MODIFIED for Task 8)
resource "aws_ecs_cluster" "main" {
  name = "strapi-ecs-cluster"

  # 👇 THIS IS THE NEW BLOCK WE ADDED FOR TASK 8
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# 2. Task Definition (Unchanged from Task 7, but essential context)
resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024" 
  memory                   = "2048" 
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
      # Logs were already set up in Task 7, but are crucial for Monitoring
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

# 3. Log Group (Unchanged)
resource "aws_cloudwatch_log_group" "strapi_logs" {
  name              = "/ecs/strapi-app"
  retention_in_days = 7
}

# 4. Service (Unchanged)
resource "aws_ecs_service" "strapi" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
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

### B. New `monitoring.tf` (Alarms & Dashboard)
This entire file is **NEW** for Task 8.

**File:** `task7-ecs/terraform/monitoring.tf`
```hcl
# 1. High CPU Alarm
# Triggers if CPU > 80% for 2 minutes
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "strapi-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 60
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.strapi.name
  }
}

# 2. High Memory Alarm
# Triggers if Memory > 80% for 2 minutes
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "strapi-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 60
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.strapi.name
  }
}

# 3. Operational Dashboard
# Visualizes CPU, Memory, Task Count, and Network I/O
resource "aws_cloudwatch_dashboard" "strapi_dashboard" {
  dashboard_name = "Strapi-Health-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.strapi.name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Service CPU & Memory"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["ECS/ContainerInsights", "TaskCount", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.strapi.name]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Running Task Count"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["ECS/ContainerInsights", "NetworkRxBytes", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.strapi.name],
            [".", "NetworkTxBytes", ".", ".", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Network Traffic (Bytes)"
        }
      }
    ]
  })
}
```

---

## 🏃 3. Execution Steps for Task 8

### 1. Apply the Changes
Because we modified `ecs.tf` and created `monitoring.tf`, Terraform needs to update the AWS infrastructure.
```bash
cd task7-ecs/terraform
terraform apply -auto-approve
```
*   **What happens**:
    *   Terraform detects the Cluster change -> Modifies Cluster to enable Insights.
    *   Terraform detects new Alarms -> Creates them.
    *   Terraform detects new Dashboard -> Creates it.

### 2. Verify in Console
1.  **Dashboard**: CloudWatch -> Dashboards -> `Strapi-Health-Dashboard`.
2.  **Alarms**: CloudWatch -> Alarms -> All alarms -> Check for `strapi-cpu-high`.
3.  **Logs**: CloudWatch -> Log Groups -> `/ecs/strapi-app`.

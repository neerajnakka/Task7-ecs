# ============================================================================
# CODEDEPLOY APPLICATION
# ============================================================================
# A CodeDeploy application is a container for deployment configurations
# It defines WHAT we're deploying (ECS service)

resource "aws_codedeploy_app" "strapi" {
  name             = "${var.project_name}-${var.unique_suffix}-app"
  compute_platform = "ECS"  # We're deploying to ECS (not EC2 or on-premises)
  
  tags = {
    Name = "${var.project_name}-${var.unique_suffix}-codedeploy-app"
  }
}

# ============================================================================
# CODEDEPLOY DEPLOYMENT GROUP
# ============================================================================
# A deployment group defines HOW we're deploying
# Fixed with the mandatory blue_green_deployment_config block for ECS

resource "aws_codedeploy_deployment_group" "strapi" {
  app_name               = aws_codedeploy_app.strapi.name
  deployment_group_name  = "${var.project_name}-${var.unique_suffix}-deployment-group"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = var.deployment_strategy
  
  # ========================================================================
  # ECS SERVICE CONFIGURATION (REQUIRED FOR ECS)
  # ========================================================================
  
  ecs_service {
    cluster_name = aws_ecs_cluster.main.name
    service_name = aws_ecs_service.strapi.name
  }
  
  # ========================================================================
  # DEPLOYMENT STYLE FOR ECS BLUE/GREEN
  # ========================================================================
  
  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }
  
  # ========================================================================
  # BLUE/GREEN DEPLOYMENT CONFIGURATION (MANDATORY FOR ECS)
  # This tells CodeDeploy what to do with blue tasks after green is live
  # ========================================================================
  
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0  # Immediate traffic switch once tasks are healthy
    }
    
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.termination_wait_time_minutes
    }
  }
  
  # ========================================================================
  # AUTOMATIC ROLLBACK CONFIGURATION (ONLY DEPLOYMENT_FAILURE FOR ECS)
  # ========================================================================
  
  auto_rollback_configuration {
    enabled = var.enable_auto_rollback
    events  = ["DEPLOYMENT_FAILURE"]
  }
  
  # ========================================================================
  # LOAD BALANCER INFO - REQUIRED FOR ECS BLUE/GREEN
  # Uses target_group_pair_info for ECS (not target_group_info)
  # ========================================================================
  
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.http.arn]
      }
      
      target_group {
        name = aws_lb_target_group.blue.name
      }
      
      target_group {
        name = aws_lb_target_group.green.name
      }
    }
  }
  
  tags = {
    Name = "${var.project_name}-${var.unique_suffix}-deployment-group"
  }
}
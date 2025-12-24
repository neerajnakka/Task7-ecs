# --- Load Balancer ---
resource "aws_lb" "main" {
  name               = "strapi-ecs-alb-neeraj"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "strapi-ecs-alb-neeraj"
  }
}

# --- Target Group ---
# --- Target Groups (Blue/Green) ---
resource "aws_lb_target_group" "blue_tg" {
  name        = "strapi-tg-blue-neeraj"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled = true
    path    = "/"
    port    = "traffic-port"
    matcher = "200-304"
    interval = 30
    timeout = 10
    healthy_threshold = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "green_tg" {
  name        = "strapi-tg-green-neeraj"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled = true
    path    = "/"
    port    = "traffic-port"
    matcher = "200-304"
    interval = 30
    timeout = 10
    healthy_threshold = 2
    unhealthy_threshold = 3
  }
}

# --- Listener (Production - Port 80) ---
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_tg.arn
  }
  
  lifecycle {
    ignore_changes = [default_action] # CodeDeploy modifies this
  }
}

# --- Listener (Test - Port 8080) ---
resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.main.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green_tg.arn
  }
  
  lifecycle {
    ignore_changes = [default_action] # CodeDeploy modifies this
  }
}



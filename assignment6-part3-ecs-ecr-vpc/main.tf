provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_ecr_repository" "flask_repo" {
  name                 = "assignment8-flask"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "express_repo" {
  name                 = "assignment8-express"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

output "flask_repo_url" {
  value = aws_ecr_repository.flask_repo.repository_url
}

output "express_repo_url" {
  value = aws_ecr_repository.express_repo.repository_url
}
# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "assignment8-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "assignment8-igw"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "assignment8-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "assignment8-public-b"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "assignment8-public-rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# --- Security Groups ---
resource "aws_security_group" "alb_sg" {
  name        = "assignment8-alb-sg"
  description = "Allow HTTP from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "assignment8-alb-sg"
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "assignment8-ecs-sg"
  description = "Allow traffic from ALB to ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "assignment8-ecs-sg"
  }
}
# --- ECS Cluster ---
resource "aws_ecs_cluster" "main" {
  name = "assignment8-cluster"
}

# --- IAM Role for ECS Task Execution ---
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "assignment8-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- CloudWatch Log Groups ---
resource "aws_cloudwatch_log_group" "flask_logs" {
  name              = "/ecs/assignment8-flask"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "express_logs" {
  name              = "/ecs/assignment8-express"
  retention_in_days = 1
}

# --- Flask Task Definition ---
resource "aws_ecs_task_definition" "flask_task" {
  family                   = "assignment8-flask-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "flask"
      image     = "${aws_ecr_repository.flask_repo.repository_url}:latest"
      essential = true
      portMappings = [
        { containerPort = 5000, hostPort = 5000, protocol = "tcp" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.flask_logs.name
          "awslogs-region"        = "ap-southeast-2"
          "awslogs-stream-prefix" = "flask"
        }
      }
    }
  ])
}

# --- Express Task Definition ---
resource "aws_ecs_task_definition" "express_task" {
  family                   = "assignment8-express-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "express"
      image     = "${aws_ecr_repository.express_repo.repository_url}:latest"
      essential = true
      portMappings = [
        { containerPort = 3000, hostPort = 3000, protocol = "tcp" }
      ]
      environment = [
        { name = "FLASK_URL", value = "http://${aws_lb.main.dns_name}:5000" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.express_logs.name
          "awslogs-region"        = "ap-southeast-2"
          "awslogs-stream-prefix" = "express"
        }
      }
    }
  ])
}
# --- Application Load Balancer ---
resource "aws_lb" "main" {
  name               = "assignment8-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

# --- Target Groups ---
resource "aws_lb_target_group" "flask_tg" {
  name        = "assignment8-flask-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/api/message"
    port                = "5000"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    interval            = 30
    timeout             = 5
  }
}

resource "aws_lb_target_group" "express_tg" {
  name        = "assignment8-express-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = "3000"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    interval            = 30
    timeout             = 5
  }
}

# --- Listeners ---
# Port 80 -> Express (frontend, default)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.express_tg.arn
  }
}

# Port 5000 -> Flask (backend, direct access for testing/API calls)
resource "aws_lb_listener" "flask_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = 5000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_tg.arn
  }
}

# --- ECS Services ---
resource "aws_ecs_service" "flask_service" {
  name            = "assignment8-flask-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.flask_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.flask_tg.arn
    container_name    = "flask"
    container_port    = 5000
  }

  depends_on = [aws_lb_listener.flask_listener]
}

resource "aws_ecs_service" "express_service" {
  name            = "assignment8-express-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.express_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.express_tg.arn
    container_name    = "express"
    container_port    = 3000
  }

  depends_on = [aws_lb_listener.http]
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

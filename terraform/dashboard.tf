
resource "aws_ecr_repository" "c22_lance_t3_dashboard" {
  name = "c22-lance-t3-dashboard"
}

resource "aws_ecs_cluster" "c22_lance_t3_cluster" {
  name = "c22-lance-t3-cluster"
}

resource "aws_iam_role" "c22_lance_ecs_execution_role" {
  name = "c22-lance-ecs-execution-role"

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

resource "aws_iam_role_policy_attachment" "c22_lance_ecs_execution_policy" {
  role       = aws_iam_role.c22_lance_ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "c22_lance_t3_dashboard_task" {
  family                   = "c22-lance-t3-dashboard-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = aws_iam_role.c22_lance_ecs_execution_role.arn


  container_definitions = jsonencode([{
    name  = "t3-dashboard"
    image = "${aws_ecr_repository.c22_lance_t3_dashboard.repository_url}:latest"
    portMappings = [{
      containerPort = 8501
      hostPort      = 8501
    }]
  }])
}

resource "aws_ecs_service" "c22_lance_t3_dashboard_service" {
  name            = "c22-lance-t3-dashboard-service"
  cluster         = aws_ecs_cluster.c22_lance_t3_cluster.id
  task_definition = aws_ecs_task_definition.c22_lance_t3_dashboard_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      "subnet-000ea47cf93520fa8",
      "subnet-0852f93e4c45bca92",
      "subnet-0f98683ef79101020"
    ]
    assign_public_ip = true
  }
}


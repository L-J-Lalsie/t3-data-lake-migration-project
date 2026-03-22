
resource "aws_ecs_task_definition" "c22_lance_t3_pipeline_task" {
  family = "c22-lance-t3-pipeline-task"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  execution_role_arn = aws_iam_role.c22_lance_ecs_execution_role.arn
  task_role_arn = aws_iam_role.c22_lance_pipeline_task_role.arn

  container_definitions = jsonencode([{
    name  = "t3-pipeline"
    image = "${aws_ecr_repository.c22_lance_t3_pipeline_ecr.repository_url}:latest"
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/c22-lance-t3-pipeline"
        "awslogs-region"        = "eu-west-2"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_iam_role" "c22_lance_pipeline_task_role" {
  name = "c22-lance-pipeline-task-role"

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

resource "aws_iam_role_policy_attachment" "c22_lance_pipeline_task_glue_policy" {
  role       = aws_iam_role.c22_lance_pipeline_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "c22_lance_pipeline_task_s3_policy" {
  role       = aws_iam_role.c22_lance_pipeline_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_cloudwatch_log_group" "c22_lance_pipeline_logs" {
  name = "/ecs/c22-lance-t3-pipeline"
}

resource "aws_ecr_repository" "c22_lance_t3_pipeline_ecr" {
  name = "c22-lance-t3-pipeline-ecr"
  }

resource "aws_scheduler_schedule" "c22_lance_scheduler" {
  name                         = "c22-lance-scheduler"
  schedule_expression = "cron(0 9-18/3 * * ? *)"

  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = aws_ecs_cluster.c22_lance_t3_cluster.arn
    role_arn = aws_iam_role.c22_lance_scheduler_role.arn
    ecs_parameters {
      task_definition_arn = aws_ecs_task_definition.c22_lance_t3_pipeline_task.arn
      launch_type         = "FARGATE"

      network_configuration {
      subnets = [
        "subnet-000ea47cf93520fa8",
        "subnet-0852f93e4c45bca92",
        "subnet-0f98683ef79101020"
      ]
        assign_public_ip = true
      }
    }
  }
}

resource "aws_iam_role" "c22_lance_scheduler_role" {
  name = "c22-lance-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "scheduler.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "c22_lance_scheduler_ecs_run_task_policy" {
  role       = aws_iam_role.c22_lance_scheduler_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

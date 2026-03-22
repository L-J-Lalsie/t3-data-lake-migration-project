
resource "aws_ecr_repository" "c22_lance_t3_report_ecr" {
  name = "c22-lance-t3-report-ecr"
}

resource "aws_lambda_function" "c22_lance_lambda" {
  function_name = "c22-lance-lambda"
  role          = aws_iam_role.c22_lance_lambda_role.arn
  image_uri     = "${aws_ecr_repository.c22_lance_t3_report_ecr.repository_url}:latest"
  package_type  = "Image"
  timeout = 60
}

resource "aws_iam_role" "c22_lance_lambda_role" {
  name = "c22-lance-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "c22_lance_lambda_policy" {
  role       = aws_iam_role.c22_lance_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "c22_lance_lambda_s3_policy" {
  role      = aws_iam_role.c22_lance_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "c22_lance_lambda_athena_policy" {
  role      = aws_iam_role.c22_lance_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
}

resource "aws_sfn_state_machine" "c22_lance_state_machine" {
  name       = "c22-lance-state-machine"
  role_arn   = aws_iam_role.c22_lance_sfn_role.arn
  type       = "STANDARD"
  definition = jsonencode({
    "StartAt": "GenerateReport",
    "States": {
                "GenerateReport": {
                "Type": "Task",
                "Resource": "arn:aws:lambda:eu-west-2:{aws_account_id}:function:c22-lance-lambda",
                "Next": "SendEmail"
                },
                "SendEmail": {
                "Type": "Task",
                "Resource": "arn:aws:states:::aws-sdk:sesv2:sendEmail",
                "Parameters": {
                    "Destination": {
                        "ToAddresses": ["{email_address}"]
                    },
                    "Content": {
                        "Simple": {
                        "Subject": { "Data": "T3 Daily Report" },
                        "Body": {
                            "Html": { "Data.$": "$.html" }
                        }
                        }
                    },
                    "FromEmailAddress": "{email_address}"
                    },
                "End": true
                }
            }
        }
    )
}

resource "aws_iam_role" "c22_lance_sfn_role" {
  name = "c22-lance-sfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "c22_lance_sfn_policy" {
  role       = aws_iam_role.c22_lance_sfn_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_iam_role_policy_attachment" "c22_lance_sfn_ses_policy" {
  role       = aws_iam_role.c22_lance_sfn_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_scheduler_schedule" "c22_lance_step_function_scheduler" {
  name                         = "c22-lance-step-function-scheduler"
  schedule_expression          = "cron(30 9 * * ? *)"

  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = aws_sfn_state_machine.c22_lance_state_machine.arn
    role_arn = aws_iam_role.c22_lance_step_function_scheduler_role.arn
  } 
}

resource "aws_iam_role" "c22_lance_step_function_scheduler_role" {
  name = "c22-lance-step-function-scheduler-role" 

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

resource "aws_iam_role_policy_attachment" "c22_lance_step_function_scheduler_policy" {
  role       = aws_iam_role.c22_lance_step_function_scheduler_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
}

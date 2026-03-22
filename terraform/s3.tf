provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "c22_lance_s3_bucket" {
  bucket = "c22-lance-s3-bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.c22_lance_s3_bucket.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_glue_catalog_database" "c22_lance_t3_database" {
  name = "c22_lance_t3_database"
}

resource "aws_iam_role" "c22_lance_glue_crawler_role" {
  name = "c22_lance_glue_crawler_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "c22_lance_glue_service_policy" {
  role       = aws_iam_role.c22_lance_glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "c22_lance_s3_read_policy" {
  role       = aws_iam_role.c22_lance_glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_glue_crawler" "c22_lance_t3_crawler" {
  name          = "c22-lance-t3-crawler"
  role          = aws_iam_role.c22_lance_glue_crawler_role.arn
  database_name = aws_glue_catalog_database.c22_lance_t3_database.name

  s3_target {
    path = "s3://c22-lance-s3-bucket/T3_data/"
  }
}


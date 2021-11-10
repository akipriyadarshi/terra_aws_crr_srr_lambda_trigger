locals {
  lambda-zip-location = "outputs/lambdacode.zip"
}


data "archive_file" "init" {
  type        = "zip"
  source_file = "lambdacode.py"
  output_path = local.lambda-zip-location
}

resource "aws_lambda_function" "test_lambda_1" {
  filename      = local.lambda-zip-location
  function_name = "lambdacode"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambdacode.hello"

 
  #source_code_hash = filebase64sha256("lambda_function_payload.zip")

  runtime = "python3.7"

  
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda_1.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.test_lambda_1.arn
    events              = ["s3:ObjectCreated:*"]
 #   filter_prefix       = "AWSLogs/"
  #  filter_suffix       = ".log"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
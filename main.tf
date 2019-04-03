variable "aws_region" {
    default = "us-east-1"
}
variable "lambda_function_name_for_ec2-stop-info" {
    default = "ec2-stop-info"}
variable "component" {
    default = "jdfdevopsci"
}


data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "stop_instance.py"
  output_path = "stop_instance.zip"
}
provider "aws" {
  region = "${var.aws_region}"
 }

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_event_rule" "stop_instances_event_rule-SP" {
  name = "stop_instances_event_rule-SP"
  description = "Stops instance alert-SP"
  event_pattern = <<PATTERN
    {
        "detail-type:": [
            "EC2 Instance State-change Notification"
        ],
        "source": [
            "aws.ec2"
        ],
        "detail": {
            "state": [
              "stopped"
        ],
        "name": [
            "test1"   
            ]
    }
   }
    PATTERN
  depends_on = ["aws_lambda_function.ec2-stop-alert-SP"]
}
resource "aws_cloudwatch_event_target" "stop_instances_event_target-SP" {
  target_id = "stop_instances_lambda_target-SP"
  rule = "${aws_cloudwatch_event_rule.stop_instances_event_rule-SP.name}"
  arn = "${aws_lambda_function.ec2-stop-alert-SP.arn}"
}
resource "aws_lambda_permission" "allow_cloudwatch_to_call_ec2-stop-alert-SP" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.ec2-stop-alert-SP.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.stop_instances_event_rule-SP.arn}"
}
resource "aws_lambda_function" "ec2-stop-alert-SP" {
  description   = "ec2 stop alert"
  filename		= "stop_instance.zip"
  function_name = "${var.lambda_function_name_for_ec2-stop-info}"
  handler       = "stop_instance.lambda_handler"
  memory_size   = "128"
  timeout       = "300"
  runtime       = "python2.7"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/A_New_Lambda"
  
}
  


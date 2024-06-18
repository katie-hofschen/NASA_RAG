provider "aws" {
  profile = "default"
  region  = "eu-west-3"
}

resource "aws_iam_role" "sagemaker_execution_role" {
  name = "sagemaker-execution-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "sagemaker.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_policy" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_sagemaker_model" "model" {
  name               = "stablelm-zephyr-3b-model"
  execution_role_arn = aws_iam_role.sagemaker_execution_role.arn
  primary_container {
    image          = "763104351884.dkr.ecr.us-west-2.amazonaws.com/huggingface-pytorch-inference:1.6.0-cpu-py36-ubuntu18.04"
    environment = {
      HF_MODEL_ID           = "stabilityai/stablelm-zephyr-3b"
      HF_TASK               = "text-generation"
    }
  }
}

resource "aws_sagemaker_endpoint_configuration" "endpoint_config" {
  name = "stablelm-zephyr-3b-endpoint-config"
  production_variants {
    variant_name           = "AllTraffic"
    model_name             = aws_sagemaker_model.model.name
    initial_instance_count = 1
    instance_type          = "ml.m5.large"
  }
}

resource "aws_sagemaker_endpoint" "endpoint" {
  name                  = "stablelm-zephyr-3b-endpoint"
  endpoint_config_name  = aws_sagemaker_endpoint_configuration.endpoint_config.name
}
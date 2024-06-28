terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "dev-profile"
}

# sagemaker.amazonaws.com assumes the role and can perform actions defined by policies
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

# This policy provides sagemake with full access to its own services to create and delete endpoints
resource "aws_iam_role_policy_attachment" "sagemaker_policy" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# Defines a ML model in Sagemaker
resource "aws_sagemaker_model" "model" {
  name               = var.model_name
  execution_role_arn = var.sagemaker_execution_role_arn
  primary_container {
    # The tgi (text-generation inference) images are needed to successfully run the model and get a response
    image          = "763104351884.dkr.ecr.eu-west-1.amazonaws.com/huggingface-pytorch-tgi-inference:2.3.0-tgi2.0.3-gpu-py310-cu121-ubuntu22.04-v2.0"
    environment = {
      HF_MODEL_ID     = "mistralai/Mistral-7B-Instruct-v0.2"
      HF_TASK         = "text-generation"
      HF_API_TOKEN    = var.hf_api_token
      # SM_NUM_GPUS     = "1"
    }
  }
}


# Defines the configuration for a sagemaker endpoint
resource "aws_sagemaker_endpoint_configuration" "endpoint_config" {
  name = "${var.endpoint_name}-config"
  production_variants {
    variant_name           = "AllTraffic"
    model_name             = aws_sagemaker_model.model.name
    initial_instance_count = 1
    instance_type          = var.instance_type
  }
}

# Sagemaker endpoint which is the actual interface of the real-time inference.
resource "aws_sagemaker_endpoint" "endpoint" {
  name                  = var.endpoint_name
  endpoint_config_name  = aws_sagemaker_endpoint_configuration.endpoint_config.name
}
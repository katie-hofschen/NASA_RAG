variable "sagemaker_execution_role_arn" {
  description = "The ARN of the IAM role that SageMaker will assume"
  type        = string
}

variable "model_name" {
  description = "The name of the SageMaker model"
  type        = string
  default     = "stablelm-zephyr-3b-model"
}

variable "endpoint_name" {
  description = "The name of the SageMaker endpoint"
  type        = string
  default     = "stablelm-zephyr-3b-endpoint"
}

variable "instance_type" {
  description = "The type of instance to use for the endpoint"
  type        = string
  default     = "ml.m5.large"
}
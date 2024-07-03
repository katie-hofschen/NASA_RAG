variable "sagemaker_execution_role_arn" {
  description = "The ARN of the IAM role that SageMaker will assume"
  type        = string
}

variable "model_name" {
  description = "The name of the SageMaker model"
  type        = string
  default     = "mistral-model"
}

variable "endpoint_name" {
  description = "The name of the SageMaker endpoint"
  type        = string
  default     = "mistral-model-endpoint"
}

variable "instance_type" {
  description = "The type of instance to use for the endpoint"
  type        = string
  default     = "ml.g4dn.xlarge"
}

variable "hf_api_token" {
  description = "The HF_API_TOKEN holds your huggingface authorization token. It is used as a HTTP bearer authorization for remote files. You can create one in your hugginface settings."
  type        = string
}
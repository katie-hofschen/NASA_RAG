provider "aws" {
  profile = "default"
  region  = "eu-west-3"
}

module "sagemaker-huggingface" {
  source                   = "philschmid/sagemaker-huggingface/aws"
  version                  = "0.2.0"
  name_prefix              = "nasa"
  pytorch_version          = "1.9.1"
  transformers_version     = "4.12.3"
  instance_type            = "ml.g4dn.xlarge"
  instance_count           = 1 # default is 1
  hf_model_id              = "nasa-base-uncased-finetuned-sst-2-english"
  hf_task                  = "text-classification"
}
terraform {
backend "s3" 
    bucket         = "tf-state-currency-converter"
    key            = "prod/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "tf-lock-table"
  }
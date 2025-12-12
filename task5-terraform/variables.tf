variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "m7i-flex.large"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu"
  default     = "ami-02b8269d5e85954ef"
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
  default     = "StrapiSecurePass2025!" # In production, pass this via -var, but for this task we default it for simplicity
}

variable "db_username" {
  description = "Username for the RDS database"
  default     = "strapi"
}

variable "db_name" {
  description = "Name of the database"
  default     = "strapidb"
}

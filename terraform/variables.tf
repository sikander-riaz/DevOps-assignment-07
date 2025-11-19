variable "ami" {
  description = "Amazon machine image to use for ec2 instance"
  type        = string
  default     = "ami-0a208b2fa6dfc6a92" # Ubuntu 24.04 LTS // 

}

variable "instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "t3.micro"
}
variable "instance_name" {
  description = "Name of ec2 instance"
  type        = string
  default     = "Host"
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "s3-bucket-name" {
  description ="name of s3 bucket"
  type = string
  default = "test-bucket-2026"
}
variable "ami" {
  description = "Amazon machine image to use for ec2 instance"
  type        = string
  default     = "ami-00f46ccd1cbfb363e" # Ubuntu 24.04 LTS // us-east-1

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
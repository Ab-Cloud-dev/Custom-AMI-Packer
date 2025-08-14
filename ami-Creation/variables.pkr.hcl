variable "ami_name" {
  description = "Name of the AMI to be created"
  type        = string
}

variable "instance_type" {
  description = "Instance type to use for building the AMI"
  type        = string
}

variable "region" {
  description = "AWS region to use"
  type        = string
}

variable "ssh_username" {
  description = "SSH username for the instance"
  type        = string
}

variable "vpc_cidr" {
  type        = string
  description = "The VPC CIDR. Please enter the value in following format X.X.X.X/16."
  default     = "10.10.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 32))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "stack_name" {
  type    = string
  default = "test"
}
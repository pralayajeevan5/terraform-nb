variable "region" {
  type        = string
  description = "AWS region to deploy to"
  default     = "ap-south-1"
}

# Consul variables

variable "consul_address" {
  type        = string
  description = "Address of consul server"
  default     = "127.0.0.1"
}

variable "consul_port" {
  type        = number
  description = "Port of consul server"
  default     = 8500
}

variable "consul_datacenter" {
  type        = string
  description = "Datacenter of consul server"
  default     = "dc1"
}

# Application variables

variable "ip_range" {
  default = "0.0.0.0/0"
}

variable "rds_username" {
  default     = "ddtuser"
  description = "Username for RDS"
}

variable "rds_password" {
  default     = "ddtpassword"
  description = "Password for RDS, provide through your env variables"
}

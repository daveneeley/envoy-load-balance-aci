variable "deployment_name" {
  type        = string
  description = "Deployment name."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "location" {
  type        = string
  description = "Private network location."
}

variable "pips_count" {
  type        = number
  description = "Number of public IPs to generate"
}

variable "frontend_ports" {
  type = list(object({
    port     = number
    protocol = string
  }))
  description = "List of front end ports to make available"
}

variable "private_subnet_id" {
  type        = string
  description = "Subnet ID to host the backend pool?"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to host the App Gateway"
}

variable "backend_pool_fqdns" {
  type        = list(string)
  description = "FQDN of backend pool nodes"
}

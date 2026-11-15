variable "okta_private_key" {
  description = "Private key for the sp-terraform-novalab-okta service app"
  type        = string
  sensitive   = true
}

variable "blocked_ip_ranges" {
  description = "IP ranges denied access to NovaLab apps"
  type        = list(string)
  default     = ["203.0.113.0/24"]
}
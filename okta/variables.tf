variable "blocked_ip_ranges" {
  description = "IP range that are denied access to the IT Portal"
  type        = list(string)
  default     = ["203.0.113.0/24"]
}
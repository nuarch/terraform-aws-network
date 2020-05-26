variable "region" {
  type = string
}

variable "availability_zone_suffixes" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "tags" {
  description = "common tags"
  type        = map(string)
  default     = {}
}

variable "secure_network_enabled" {
  description = "Setup DMZ, NATs, and optional Bastion Instances for a secure network layout."
  type        = bool
  default     = false
}

variable "allowed_source_ip_range" {
  type = string
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

variable "dmz_subnet_cidr" {
  description = "CIDR for the dmz (public) Subnet. Default will allow 512 IP addresses per subnet (reserved for 4 az)."
  default     = "10.0.64.0/21"
}

variable "app_subnet_cidr" {
  description = "CIDR for the app (private) Subnet. Default will allow 1024 IP addresses per subnet (reserved for 4 az)."
  default     = "10.0.0.0/20"
}

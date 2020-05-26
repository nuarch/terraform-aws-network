// AWS

variable "aws_profile" {
  default = "default"
}

variable "region" {
  default = "us-east-2"
}

variable "availability_zone_suffixes" {
  default = ["a", "b", "c"]
}

// Network

variable "secure_network_enabled" {
  description = "Setup DMZ, NATs, and optional Bastion Instances for a secure network layout."
  type        = bool
  default     = false
}

variable "allowed_source_ip_range" {
  description = "Restict network access to range of source IPs"
  default     = "0.0.0.0/0" // Change to your IP Range
}

// Bastion

variable "bastion_instances_enabled" {
  description = "Deploy bastion instances to secure upstream nodes."
  type        = bool
  default     = true
}

variable "key_name" {
  description = "Used for bastion ssh access (and upstream servers)"
  default     = "bastion" // Change your key name
}

variable "instance_type" {
  default = "t2.nano"
}

variable "amis" {
  description = "Instance image"
  type        = map(string)
  default = {
    us-east-2 = "ami-0516c27447372d3e5" // ubuntu-minimal/images/hvm-ssd/ubuntu-bionic-18.04-amd64-minimal-2020
  }
}

// Environment & tags

variable "environment" {
  default = "DEV"
}

variable "tags" {
  description = "common tags"
  type        = map(string)
  default = {
    "LaunchedBy" = "terraform"
    "Project"    = "terraform-aws-network"
    "Owner"      = "DevOps"
    "Purpose"    = "Operations"
  }
}

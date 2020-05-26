variable "region" {
  type = string
}

variable "availability_zone_suffixes" {
  type = list(string)
}

variable "dmz_subnet_ids" {
  type = list(string)
}

variable "app_subnet_ids" {
  type = list(string)
}

variable "bastion_ssh_sg_id" {
  type = string
}

variable "ssh_from_bastion_sg_id" {
  type = string
}

variable "key_name" {
  description = "Used for bastion ssh access (and upstream servers)"
  default     = "bastion" // Change your key name
}

variable "bastion_instances_enabled" {
  description = "Deploy bastion instances to secure upstream hosts."
  default     = false
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "instance_type" {
}

variable "amis" {
  description = "Instance image"
  type        = map(string)
  default     = {}
}

locals {
  tags = merge({ Environment = var.environment }, var.tags)
}

provider "aws" {
  profile = var.aws_profile
  region  = var.region
  version = "2.54.0"
}

module "bastion" {
  source                     = "./bastion"
  region                     = var.region
  availability_zone_suffixes = var.availability_zone_suffixes
  app_subnet_ids             = module.site.app_subnet_ids
  dmz_subnet_ids             = module.site.dmz_subnet_ids
  bastion_ssh_sg_id          = var.secure_network_enabled ? module.site.ssh_dmz_sg_id[0] : ""
  ssh_from_bastion_sg_id     = var.secure_network_enabled ? module.site.ssh_from_dmz_sg_id[0] : ""
  key_name                   = var.key_name
  amis                       = var.amis
  instance_type              = var.instance_type
  bastion_instances_enabled  = var.secure_network_enabled && var.bastion_instances_enabled ? true : false
  tags                       = local.tags
}

module "site" {
  source                     = "./site"
  region                     = var.region
  availability_zone_suffixes = var.availability_zone_suffixes
  environment                = var.environment
  tags                       = local.tags
  secure_network_enabled     = var.secure_network_enabled
  allowed_source_ip_range    = var.allowed_source_ip_range

}

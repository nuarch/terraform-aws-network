locals {
  availability_zones = formatlist("%s%s", var.region, var.availability_zone_suffixes)
  dmz_subnet_tags    = { purpose_dmz = true }
  app_subnet_tags    = { purpose_app = true }
}

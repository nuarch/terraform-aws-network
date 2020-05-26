locals {
  availability_zones = formatlist("%s%s", var.region, var.availability_zone_suffixes)
}

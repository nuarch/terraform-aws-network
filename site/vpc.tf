// VPC

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = merge({ Name = var.environment }, var.tags)
}
output "main_vpc_id" {
  value = aws_vpc.main.id
}

// Internet gateway

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.main.id
  tags   = merge({ Name = format("%s_igw", lower(var.environment)) }, var.tags)
}

// Elastic IPs - 1 per availability zone

resource "aws_eip" "nat_eips" {
  count = var.secure_network_enabled == true ? length(local.availability_zones) : 0
  vpc   = true
  tags  = merge({ Name = format("eip_%s", var.availability_zone_suffixes[count.index]) }, var.tags, local.dmz_subnet_tags)
}

// DMZ Subnets

resource "aws_subnet" "dmz" {
  count             = var.secure_network_enabled == true ? length(local.availability_zones) : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.dmz_subnet_cidr, 2, count.index)
  availability_zone = element(local.availability_zones, count.index)
  tags              = merge({ Name = format("dmz_%s", var.availability_zone_suffixes[count.index]) }, var.tags, local.dmz_subnet_tags)
}
output "dmz_subnet_ids" {
  value = aws_subnet.dmz.*.id
}

// 1 Nat per DMZ subnet
resource "aws_nat_gateway" "nats" {
  count         = var.secure_network_enabled == true ? length(local.availability_zones) : 0
  allocation_id = aws_eip.nat_eips[count.index].id
  subnet_id     = aws_subnet.dmz[count.index].id
  depends_on    = [aws_internet_gateway.default]
  tags          = merge({ Name = format("nat_%s", var.availability_zone_suffixes[count.index]) }, var.tags)
}

resource "aws_route_table" "dmz" {
  count  = var.secure_network_enabled == true ? 1 : 0
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
  tags = merge({ Name = "dmz_rt" }, var.tags)
}

resource "aws_route_table_association" "dmz" {
  count          = var.secure_network_enabled == true ? length(local.availability_zones) : 0
  subnet_id      = aws_subnet.dmz[count.index].id
  route_table_id = aws_route_table.dmz[0].id
}

// APP Subnets

resource "aws_subnet" "app" {
  count             = length(local.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.app_subnet_cidr, 2, count.index)
  availability_zone = element(local.availability_zones, count.index)
  tags              = merge({ Name = format("app_%s", var.availability_zone_suffixes[count.index]) }, var.tags, local.app_subnet_tags)
}
output "app_subnet_ids" {
  value = aws_subnet.app.*.id
}

resource "aws_route_table" "app_with_dmz" {
  count  = var.secure_network_enabled == true ? length(local.availability_zones) : 0
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nats[count.index].id
  }
  tags = merge({ Name = format("app_rt_%s", var.availability_zone_suffixes[count.index]) }, var.tags)
}

resource "aws_route_table" "app_without_dmz" {
  count  = var.secure_network_enabled == false ? length(local.availability_zones) : 0
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
  tags = merge({ Name = format("app_rt_%s", var.availability_zone_suffixes[count.index]) }, var.tags)
}

resource "aws_route_table_association" "app" {
  count          = length(local.availability_zones)
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = var.secure_network_enabled == true ? aws_route_table.app_with_dmz[count.index].id : aws_route_table.app_without_dmz[count.index].id
}

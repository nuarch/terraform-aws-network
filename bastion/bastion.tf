resource "aws_instance" "bastion" {
  count                       = var.bastion_instances_enabled == true ? length(local.availability_zones) : 0
  ami                         = lookup(var.amis, var.region)
  instance_type               = var.instance_type
  subnet_id                   = var.dmz_subnet_ids[count.index]
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.bastion_ssh_sg_id]
  key_name                    = var.key_name
  tags                        = merge({ Name = format("bastion_%s", var.availability_zone_suffixes[count.index]) }, var.tags)
}

resource "aws_eip" "bastion" {
  count    = var.bastion_instances_enabled == true ? length(local.availability_zones) : 0
  instance = aws_instance.bastion[count.index].id
  tags     = merge({ Name = format("bastion_eip_%s", var.availability_zone_suffixes[count.index]) }, var.tags, var.tags)
  vpc      = true
}

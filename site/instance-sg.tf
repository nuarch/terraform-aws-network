resource "aws_security_group" "ssh_dmz_sg" {
  count       = var.secure_network_enabled == true ? 1 : 0
  description = "Allow SSH to host in DMZ from approved ranges"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_source_ip_range]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.main.id
  tags   = merge({ Name = "ssh_dmz" }, var.tags)
}
output "ssh_dmz_sg_id" {
  value = aws_security_group.ssh_dmz_sg.*.id
}

resource "aws_security_group" "ssh_from_dmz_sg" {
  count       = var.secure_network_enabled == true ? 1 : 0
  description = "Allow SSH from host(s) in DMZ"
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    security_groups = [
      aws_security_group.ssh_dmz_sg[0].id
    ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.main.id
  tags   = merge({ Name = "ssh_from_dmz" }, var.tags)
}
output "ssh_from_dmz_sg_id" {
  value = aws_security_group.ssh_from_dmz_sg.*.id
}

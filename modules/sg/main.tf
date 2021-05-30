locals {
    app_sg_ingress_rules = var.sg_ingress_rules
    app_sg_egress_rules = var.sg_egress_rules
}

resource "aws_security_group" "app_sg" {
    name        = "${var.appname}_SG"
    description = var.description
    vpc_id      = var.vpc_id
    tags = {
        Name = "${var.appname}_SG"
    }
}

resource "aws_security_group_rule" "app_sg_ingress" {
    count = length(local.app_sg_ingress_rules)
    type = "ingress"
    from_port = local.app_sg_ingress_rules[count.index].from_port
    to_port = local.app_sg_ingress_rules[count.index].to_port
    protocol = local.app_sg_ingress_rules[count.index].protocol
    cidr_blocks = [local.app_sg_ingress_rules[count.index].cidr_block]
    description = local.app_sg_ingress_rules[count.index].description
    security_group_id =  aws_security_group.app_sg.id
}

resource "aws_security_group_rule" "app_sg_egress" {
    count = length(local.app_sg_egress_rules)
    type = "egress"
    from_port = local.app_sg_egress_rules[count.index].from_port
    to_port = local.app_sg_egress_rules[count.index].to_port
    protocol = local.app_sg_egress_rules[count.index].protocol
    cidr_blocks = [local.app_sg_egress_rules[count.index].cidr_block]
    description = local.app_sg_egress_rules[count.index].description
    security_group_id =  aws_security_group.app_sg.id
}

output "security_group_id" {
  value = aws_security_group.app_sg.id
}
data "aws_vpc" "vpc" {
    id = var.vpc_id
}

locals {
    mediawiki_sg_ingress_rules = [
        {
            from_port = 3306,
            to_port =  3306,
            protocol = "tcp",
            cidr_block = data.aws_vpc.vpc.cidr_block
            description = "MYSQL port for RDS connections"
        },
        {
            from_port = 80,
            to_port =  80,
            protocol = "tcp",
            cidr_block = "0.0.0.0/0"
            description = "http connections"
        }
    ]

    mediawiki_sg_egress_rules = [
        {
            from_port = 0,
            to_port =  0,
            protocol = "-1",
            cidr_block = "0.0.0.0/0",
            description = "All Traffic"
        }  
    ]
}

module "mediawiki_sg" {
    source = "../../modules/sg"
    appname = var.name
    description = "Mediawiki inbound and outbound rules"
    vpc_id = var.vpc_id
    sg_ingress_rules = local.mediawiki_sg_ingress_rules
    sg_egress_rules = local.mediawiki_sg_egress_rules
}
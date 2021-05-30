variable "appname" {}

variable "description" {}

variable "vpc_id" {}

variable "sg_ingress_rules" {
    type = list(object({
        from_port = number
        to_port = number
        protocol = string
        cidr_block = string
        description = string
    }))
    default = []
}

variable "sg_egress_rules" {
    type = list(object({
        from_port = number
        to_port = number
        protocol = string
        cidr_block = string
        description = string
    }))
    default = []
}

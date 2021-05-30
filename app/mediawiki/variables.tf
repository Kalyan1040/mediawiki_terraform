variable "name" {
    default = "mediawiki"
}

variable "mediawiki_version" {
    default = "1.36.0"
}

variable "instancetype" {
    default = ""
}
variable "key" {
    default = "ec2kk"
}
variable "ec2_type" {
    default = "t2.micro"
}

variable "vpc_id" {
    default = ""
}

variable "db_root_pass" {
    default = ""
}

variable "db_wiki_pass" {
    default = ""
}



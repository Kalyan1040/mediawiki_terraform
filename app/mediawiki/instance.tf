data "aws_ami" "rhel" {
  most_recent      = true
  name_regex       = "RHEL_HA-8*"
  owners           = ["309956199498"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_subnet_ids" "subnet" {
    vpc_id = var.vpc_id
}

locals{
    userdata_bootstrap = <<USERDATA
#!/bin/sh
dnf module reset php -y
dnf module enable php:7.4 -y 
dnf install wget httpd php php-mysqlnd php-gd php-xml mariadb-server mariadb php-mbstring php-json php-intl -y
systemctl start mariadb
mysqladmin -u root password "${var.db_root_pass}"
mysql -u root -p"${var.db_root_pass}" -e "UPDATE mysql.user SET Password=PASSWORD('${var.db_root_pass}') WHERE User='root'"
mysql -u root -p"${var.db_root_pass}" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -p"${var.db_root_pass}" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"${var.db_root_pass}" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"${var.db_root_pass}" -e "FLUSH PRIVILEGES"
mysql -u root -p"${var.db_root_pass}" -e "CREATE USER 'wiki'@'localhost' IDENTIFIED BY '${var.db_wiki_pass}'"
mysql -u root -p"${var.db_root_pass}" -e "CREATE DATABASE database_name"
mysql -u root -p"${var.db_root_pass}" -e "CREATE DATABASE wikidatabase"
mysql -u root -p"${var.db_root_pass}" -e "GRANT ALL PRIVILEGES ON wikidatabase.* TO 'wiki'@'localhost'"
mysql -u root -p"${var.db_root_pass}" -e "FLUSH PRIVILEGES"
systemctl enable mariadb
systemctl enable httpd
cd /tmp && wget https://releases.wikimedia.org/mediawiki/1.36/mediawiki-${var.mediawiki_version}.tar.gz
cd /var/www && tar -xvf /tmp/mediawiki-${var.mediawiki_version}.tar.gz
ln -s mediawiki-${var.mediawiki_version}/ mediawiki
sed -i "s/\/var\/www\/html/\/var\/www\/mediawiki/g" /etc/httpd/conf/httpd.conf
service httpd restart
USERDATA
}


module "mediawiki_ec2_instance" {
    source = "../../modules/ec2"
    appname = var.name
    ami = data.aws_ami.rhel.id
    ec2_type = var.instancetype
    keyname = var.key
    sg_id = [module.mediawiki_sg.security_group_id]
    subnetid = tolist(data.aws_subnet_ids.subnet.ids)[0]
    user_data = base64encode(local.userdata_bootstrap)
    rootvolumesize = "10"
}
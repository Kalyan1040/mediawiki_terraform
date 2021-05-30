resource "aws_instance" "ec2" {
    ami                     = var.ami
    instance_type           = var.ec2_type
    key_name                = var.keyname
    ebs_optimized           = false
    vpc_security_group_ids  = var.sg_id
    subnet_id   = var.subnetid
    
    user_data_base64        = var.user_data

    metadata_options {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
    }

    root_block_device {
        volume_type           = "gp2"
        volume_size           = var.rootvolumesize
        delete_on_termination = var.delete_on_termination
    }

    tags = {
        Name = "${var.appname}"
    }
}

output "instance_id" {
    value       = aws_instance.ec2.id
}

output "instance_public_ip" {
    description     = "List of all public ips attached to an instance"
    value           = aws_instance.ec2.public_ip
}

output "instance_private_ip" {
    description     = "List of all private ips attached to an instance"
    value           = aws_instance.ec2.private_ip
}
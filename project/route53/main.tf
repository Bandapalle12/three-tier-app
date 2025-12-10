data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "ecs_dns" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  allow_overwrite = true

  # IP of EC2 instance passed from main.tf
  records = [var.ec2_public_ip]
}



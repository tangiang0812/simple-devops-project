# resource "aws_route53_zone" "route53_zone" {
#   name = var.domain_name
# } 
# remove from terraform state and import existing zone

data "aws_route53_zone" "route53_zone" {
  zone_id = var.route53_zone_id
  # private_zone = false
  # name         = var.domain_name
}

resource "aws_route53_record" "record" {
  # zone_id = aws_route53_zone.route53_zone.id
  zone_id = data.aws_route53_zone.route53_zone.id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alias_dns_name
    zone_id                = var.alias_hosted_zone_id
    evaluate_target_health = true
  }
}



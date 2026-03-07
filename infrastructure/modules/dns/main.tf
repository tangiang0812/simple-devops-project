resource "aws_route53_zone" "gitlab_zone" {
  name = var.domain_name
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "gitlab_alb_record" {
  zone_id = aws_route53_zone.gitlab_zone.id
  name    = "gitlab.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.nlb_dns_name
    zone_id                = var.nlb_hosted_zone_id
    evaluate_target_health = true
  }
}


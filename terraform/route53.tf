resource "aws_route53_health_check" "failover_health_check" {
  fqdn              = "your-domain"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
}

output "health_check_id" {
  value = aws_route53_health_check.failover_health_check.id
}

resource "aws_route53_record" "failover_record" {
  zone_id = "****************"
  name    = "your-domain"
  type    = "A"
  set_identifier = "primary"
  failover_routing_policy {
    type = "PRIMARY"
  }
  health_check_id = aws_route53_health_check.failover_health_check.id
  records = [aws_instance.primary_instance.public_ip]
  ttl     = 60
}

resource "aws_route53_record" "failover_record_secondary" {
  zone_id = "*****************"
  name    = "your-domain"
  type    = "A"
  set_identifier = "secondary"
  failover_routing_policy {
    type = "SECONDARY"
  }
  health_check_id = aws_route53_health_check.failover_health_check.id
  records = [aws_instance.secondary_instance.public_ip]
  ttl     = 60
}

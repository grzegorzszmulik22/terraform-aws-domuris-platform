output "alb_arn" {
  description = "ALB ARN."
  value       = aws_lb.this.arn
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix used by CloudWatch metrics."
  value       = aws_lb.this.arn_suffix
}

output "alb_dns_name" {
  description = "ALB DNS name."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "ALB zone ID."
  value       = aws_lb.this.zone_id
}

output "security_group_id" {
  description = "ALB security group ID."
  value       = aws_security_group.alb.id
}

output "api_target_group_arn" {
  description = "API target group ARN."
  value       = aws_lb_target_group.api.arn
}

output "api_target_group_arn_suffix" {
  description = "API target group ARN suffix used by CloudWatch metrics."
  value       = aws_lb_target_group.api.arn_suffix
}

output "waf_web_acl_arn" {
  description = "WAF web ACL ARN when enabled."
  value       = try(aws_wafv2_web_acl.this[0].arn, null)
}

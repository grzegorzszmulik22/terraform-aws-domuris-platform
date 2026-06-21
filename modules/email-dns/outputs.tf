output "domain_identity_arn" {
  description = "SES domain identity ARN."
  value       = aws_ses_domain_identity.this.arn
}

output "mail_from_domain" {
  description = "Configured MAIL FROM domain."
  value       = local.mail_from_domain
}

output "dkim_record_names" {
  description = "DKIM Route53 record names."
  value       = aws_route53_record.dkim[*].fqdn
}

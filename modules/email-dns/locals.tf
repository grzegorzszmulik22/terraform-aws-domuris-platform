locals {
  mail_from_domain = "${var.mail_from_subdomain}.${var.domain_name}"
  dmarc_value = var.dmarc_reports_email == null ? (
    "v=DMARC1; p=${var.dmarc_policy}; pct=100"
    ) : (
    "v=DMARC1; p=${var.dmarc_policy}; pct=100; rua=mailto:${var.dmarc_reports_email}"
  )
}

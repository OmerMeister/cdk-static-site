#just for info

# cloudfront distribution native domain
output "cloudfront_distribution_native_domain" {
  value = aws_cloudfront_distribution.dp1000_cf_distribution.domain_name
}
# website domain
output "website_domain" {
  value = var.project_domain_name
}
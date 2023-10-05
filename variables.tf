# general certificate for the *.meister.lol domain. managed outside of terraform for convinience.
variable "meister_lol_certificate_us_east_1" {
  type    = string
  default = "arn:aws:acm:us-east-1:671231939531:certificate/b708da75-9abf-477b-b2f1-4831be03368b"
}

# domain name of the website
# webcontent s3 bucket name
# webcontent bucket policy uses it
# pipeline artifacts s3 bucket derivates its name from it
# oac uses a derivate of it
# cloudfront uses it in various places
variable "project_domain_name" {
  type    = string
  default = "dp1000.meister.lol"
}
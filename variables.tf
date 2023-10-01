# general certificate for the *.meister.lol domain. managed outside of terraform for convinience.
variable "meister_lol_certificate_us_east_1" {
  type    = string
  default = "arn:aws:acm:us-east-1:671231939531:certificate/b708da75-9abf-477b-b2f1-4831be03368b"
}

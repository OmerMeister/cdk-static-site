
terraform {
  required_version = ">= 1.1.2"
  cloud {
    organization = "OmerMeister"

    workspaces {
      name = "dp1000"
    }
  }
}

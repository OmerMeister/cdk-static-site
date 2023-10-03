# Static site Deployment using terraform. project-tf1000

This project demonstrates provisioning of a aws static site using terraform.
This site is simple, but yet, more complicated than the ususal S3 bucket static site.
The site extra featurs are: better access worldwide due to using CloudFront CDN,
use a ssl certificate to encrypt the connection to the site, and custom error pages
The static files for the website can be found [On this repo](https://github.com/OmerMeister/tf1000).

## What's here?

This repo contains two main things:

1. An example Terraform configuration which provisions some mock infrastructure to a fictitious cloud provider called "Fake Web Services" using the [`fakewebservices`](https://registry.terraform.io/providers/hashicorp/fakewebservices/latest) provider.
1. A [script](./scripts/setup.sh) which automatically handles all the setup required to start using Terraform with Terraform Cloud.

![Arcitecture](auxiliary/graph.jpg)

## Requirements

- Terraform 0.14 or higher
- The ability to run a bash script in your terminal
- [`sed`](https://www.gnu.org/software/sed/)
- [`curl`](https://curl.se/)
- [`jq`](https://stedolan.github.io/jq/)

## Usage

### 1. Log in to Terraform Cloud via the CLI

Run `terraform login` and follow the prompts to get an API token for Terraform to use. If you don't have a Terraform Cloud account, you can create one during this step.

### 2. Clone this repo

```sh
git clone https://github.com/hashicorp/tfc-getting-started.git
cd tfc-getting-started
```

### 3. Run the setup script and follow the prompts

```
./scripts/setup.sh
```

Welcome to Terraform Cloud!

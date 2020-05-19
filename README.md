# AWS Public MSK Terraform module

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/cgetzen/terraform-aws-public-msk)


Terraform module that exposes an existing MSK cluster to the internet.

## Usage

```hcl
module "public_msk" {
  source = "cgetzen/public-msk/aws"

  cluster_name     = "production-app1"
  propogate_tags   = true
  check_errors     = true
  create_host_file = true
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | The existing MSK cluster | `string` | `""` | yes |
| propogate\_tags | Propogate MSKs tags to the EIPs | `bool` | `true` | no |
| check\_errors | Checks if MSK is configured properly | `bool` | `true` | no |
| create\_host\_file | Creates /etc/hosts file necessary to connect to MSK | `bool` | `true` | no |
| tags | Additional EIP tags | `map(string)` | `{}` | no |

## Requirements

- An existing MSK cluster. It is better to put this in a different state file, to avoid needing to target when building.
- MSK in public subnets. `check_errors` will confirm this for you by looking if the subnets use an IGW instead of a NAT.
- MSK configured to use TLS certificates. You don't want to expose it otherwise!

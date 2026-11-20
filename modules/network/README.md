# network

VPC with public subnets for load balancers and private subnets for workloads and data stores.

## What it creates

- VPC with DNS support and hostnames
- Internet gateway and public subnets, one per CIDR, across availability zones
- Private subnets, one per CIDR, across availability zones
- Optional single NAT gateway for private subnet egress

## Security defaults

- Public subnets do not assign public IPs on launch
- Private subnets have no route to the internet gateway

## Usage

See [`examples/`](../../examples) for a full composition.

```hcl
module "network" {
  source = "git::https://github.com/grzegorzszmulik22/terraform-aws-domuris-platform.git//modules/network?ref=v0.1.1"
  # required inputs listed below
}
```

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `environment` | Deployment environment. | `string` | n/a | yes |
| `private_subnet_cidrs` | CIDR blocks for private subnets. | `list(string)` | n/a | yes |
| `project` | Project name used in resource names. | `string` | n/a | yes |
| `public_subnet_cidrs` | CIDR blocks for public subnets. | `list(string)` | n/a | yes |
| `vpc_cidr` | CIDR block for the VPC. | `string` | n/a | yes |
| `enable_nat_gateway` | Whether private subnets should route through a NAT gateway. | `bool` | `true` | no |
| `tags` | Tags applied to all supported resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `private_subnet_ids` | Private subnet IDs. |
| `public_subnet_ids` | Public subnet IDs. |
| `vpc_cidr_block` | VPC CIDR block. |
| `vpc_id` | VPC ID. |
<!-- END_TF_DOCS -->

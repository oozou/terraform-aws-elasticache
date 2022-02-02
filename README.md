# AWS Elasticache Cluster

ElastiCache is a fully managed in-memory data store and cache service. This component creates an elasticache cluster with encryption enabled. [Read more](https://aws.amazon.com/elasticache/)

It creates:

- Elasticache replication group: Redis with Elasticache Cluster Mode Enabled.
- High Availability elasticache cluster with automatic failover and auto minor version upgrade
- Automatic backup and maintenance
- Encryption enabled at rest and transit by default

## Architecture

![Arch](./architecture.png)

## Run-Book

### Pre-requisites
  
#### IMPORTANT NOTE

1. Required version of Terraform is mentioned in `versions.tf`.
2. Go through `variables.tf` for understanding each terraform variable before running this component.

#### Resources needed before deploying this component

1. VPC with Private Subnets

#### AWS Accounts

Needs the following accounts:

1. Any AWS Account where Elasticache needs to be deployed

### Getting Started

#### How to use this component in a blueprint

IMPORTANT: We periodically release versions for the components. Since, master branch may have on-going changes, best practice would be to use a released version in form of a tag (e.g. ?ref=x.y.z)

```terraform
module "elasticache_cluster" {
  source         = "git::https://<YOUR_VCS_URL>/components/terraform-aws-elasticache.git?ref=v4.0.0"
  base_name         = "${var.base_name}--redis-"
  vpc_config        = {
    vpc_id = module.vpc.vpc_id
    private_subnets = [module.vpc.private_subnet_ids]
  }

  redis_cluster_config = {
    instance_type  = var.elasticache["instance_type"]
    node_count     = var.elasticache["node_count"]
    engine_version = "5.0.6"

  }

  auth_token     = var.elasticache["redis_auth_token"]
  multi_az_enabled = var.multi_az_enabled
}
```

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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0, < 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0, < 6.0.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_custom_elasticache_alarms"></a> [custom\_elasticache\_alarms](#module\_custom\_elasticache\_alarms) | oozou/cloudwatch-alarm/aws | 2.0.1 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.redis_cpu_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.redis_memory_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_elasticache_replication_group.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_serverless_cache.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_serverless_cache) | resource |
| [aws_elasticache_subnet_group.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_security_group.client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.additional_cluster_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [null_resource.validate_config](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_subnet.subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_cluster_security_group_ingress_rules"></a> [additional\_cluster\_security\_group\_ingress\_rules](#input\_additional\_cluster\_security\_group\_ingress\_rules) | Additional ingress rule for cluster security group. | <pre>list(object({<br>    from_port                = number<br>    to_port                  = number<br>    protocol                 = string<br>    cidr_blocks              = list(string)<br>    source_security_group_id = string<br>    description              = string<br>  }))</pre> | `[]` | no |
| <a name="input_auth_token"></a> [auth\_token](#input\_auth\_token) | Auth token for the Elasticache redis/valkey auth. Reference: https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/auth.html | `string` | `null` | no |
| <a name="input_cache_type"></a> [cache\_type](#input\_cache\_type) | Type of cache to create. Valid values: redis, valkey, redis-serverless, valkey-serverless | `string` | `"redis"` | no |
| <a name="input_custom_elasticache_alarms_configure"></a> [custom\_elasticache\_alarms\_configure](#input\_custom\_elasticache\_alarms\_configure) | custom\_elasticache\_alarms\_configure = {<br>      cpu\_utilization\_too\_high = {<br>        metric\_name         = "EngineCPUUtilization"<br>        statistic           = "Average"<br>        comparison\_operator = ">="<br>        threshold           = "85"<br>        period              = "300"<br>        evaluation\_periods  = "1"<br>        alarm\_actions       = [sns\_topic\_arn]<br>        ok\_actions       = [sns\_topic\_arn]<br>      }<br>    } | `any` | `{}` | no |
| <a name="input_default_alarm_actions"></a> [default\_alarm\_actions](#input\_default\_alarm\_actions) | The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_default_ok_actions"></a> [default\_ok\_actions](#input\_default\_ok\_actions) | The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment Variable used as a prefix | `string` | n/a | yes |
| <a name="input_is_enable_default_alarms"></a> [is\_enable\_default\_alarms](#input\_is\_enable\_default\_alarms) | if enable the default alarms | `bool` | `false` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Snapshot Retention Limit | `string` | `"mon:00:00-mon:03:00"` | no |
| <a name="input_multi_az_enabled"></a> [multi\_az\_enabled](#input\_multi\_az\_enabled) | Specifies whether to enable Multi-AZ Support for the replication group (traditional clusters only) | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ElastiCache cluster to create | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix name of customer to be displayed in AWS console and resource | `string` | n/a | yes |
| <a name="input_redis_cluster_config"></a> [redis\_cluster\_config](#input\_redis\_cluster\_config) | Configuration for traditional redis/valkey cluster (not used for serverless) | <pre>object({<br>    port           = number<br>    instance_type  = string<br>    engine_version = string<br>    node_count     = number<br>  })</pre> | `null` | no |
| <a name="input_serverless_config"></a> [serverless\_config](#input\_serverless\_config) | Configuration for serverless cache | <pre>object({<br>    engine_version       = string<br>    major_engine_version = optional(string)<br>    cache_usage_limits = optional(object({<br>      data_storage = optional(object({<br>        maximum = number<br>        unit    = string<br>      }))<br>      ecpu_per_second = optional(object({<br>        maximum = number<br>      }))<br>    }))<br>    daily_snapshot_time      = optional(string)<br>    description              = optional(string)<br>    kms_key_id               = optional(string)<br>    snapshot_arns_to_restore = optional(list(string))<br>    snapshot_retention_limit = optional(number)<br>    user_group_id            = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_serverless_security_group_ids"></a> [serverless\_security\_group\_ids](#input\_serverless\_security\_group\_ids) | List of security group IDs for serverless cache (required for serverless caches) | `list(string)` | `[]` | no |
| <a name="input_snapshot_config"></a> [snapshot\_config](#input\_snapshot\_config) | (optional) Snapshot config to retain and create backup | <pre>object({<br>    snapshot_window          = string<br>    snapshot_retention_limit = number<br>  })</pre> | <pre>{<br>  "snapshot_retention_limit": 3,<br>  "snapshot_window": "03:00-05:00"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys. | `map(string)` | `{}` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC ID and private subnets for ElastiCache cluster | <pre>object({<br>    vpc_id          = string<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cache_engine"></a> [cache\_engine](#output\_cache\_engine) | Cache engine (redis or valkey). |
| <a name="output_cache_host"></a> [cache\_host](#output\_cache\_host) | Hostname of the cache endpoint (traditional cluster primary endpoint or serverless endpoint). |
| <a name="output_cache_port"></a> [cache\_port](#output\_cache\_port) | Port of the cache endpoint. |
| <a name="output_cache_type"></a> [cache\_type](#output\_cache\_type) | Type of cache created (redis, valkey, redis-serverless, valkey-serverless). |
| <a name="output_client_security_group_id"></a> [client\_security\_group\_id](#output\_client\_security\_group\_id) | Security group id for the elasticache clients. |
| <a name="output_is_serverless"></a> [is\_serverless](#output\_is\_serverless) | Whether the cache is serverless. |
| <a name="output_redis_host"></a> [redis\_host](#output\_redis\_host) | Hostname of the redis/valkey host in the replication group (traditional clusters only). |
| <a name="output_replication_group_id"></a> [replication\_group\_id](#output\_replication\_group\_id) | ID of the ElastiCache replication group (traditional clusters only). |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group id for the elasticache. |
| <a name="output_serverless_cache_arn"></a> [serverless\_cache\_arn](#output\_serverless\_cache\_arn) | ARN of the serverless cache (serverless caches only). |
| <a name="output_serverless_cache_name"></a> [serverless\_cache\_name](#output\_serverless\_cache\_name) | Name of the serverless cache (serverless caches only). |
<!-- END_TF_DOCS -->

/* -------------------------------------------------------------------------- */
/*                                   Generic                                  */
/* -------------------------------------------------------------------------- */

variable "name" {
  description = "Name of the ECS cluster to create"
  type        = string
}

variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
}

variable "prefix" {
  description = "The prefix name of customer to be displayed in AWS console and resource"
  type        = string
}

variable "tags" {
  description = "Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys."
  type        = map(string)
  default     = {}
}
/* -------------------------------------------------------------------------- */
/*                                 ElastiCache                                */
/* -------------------------------------------------------------------------- */


# variable "base_name" {
#   description = "Base name used in naming resources created in this component"
#   type        = string
# }

variable "vpc_config" {
  description = "VPC ID and private subnets for ElastiCache cluster"
  type = object({
    vpc_id          = string
    private_subnets = list(string)
  })
}

variable "redis_cluster_config" {
  description = "Configuration for redis cluster"
  type = object({
    port           = number
    instance_type  = string
    engine_version = string
    node_count     = number
  })
}

variable "auth_token" {
  description = "Auth token for the Elasticache redis auth. Reference: https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/auth.html"
  type        = string
}

variable "snapshot_config" {
  description = "(optional) Snapshot config to retain and create backup"
  type = object({
    snapshot_window          = string
    snapshot_retention_limit = number
  })
  default = {
    snapshot_retention_limit = 3
    snapshot_window          = "03:00-05:00"
  }
}

variable "maintenance_window" {
  description = "Snapshot Retention Limit"
  type        = string
  default     = "mon:00:00-mon:03:00"
}

variable "multi_az_enabled" {
  description = "Specifies whether to enable Multi-AZ Support for the replication group"
  type        = bool
}

variable "additional_cluster_security_group_ingress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = list(string)
    source_security_group_id = string
    description              = string
  }))
  description = "Additional ingress rule for cluster security group."
  default     = []
}
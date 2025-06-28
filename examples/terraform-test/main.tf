/* -------------------------------------------------------------------------- */
/*                                   Data                                     */
/* -------------------------------------------------------------------------- */
data "aws_caller_identity" "this" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# Traditional Redis cluster for testing
module "redis_traditional" {
  source = "../../"

  prefix      = var.prefix
  environment = var.environment
  name        = "redis-test"

  cache_type = "redis"

  vpc_config = {
    vpc_id          = module.vpc.vpc_id
    private_subnets = module.vpc.private_subnet_ids
  }

  redis_cluster_config = {
    port           = 6379,
    instance_type  = "cache.t3.micro",
    engine_version = "7.0",
    node_count     = 2
  }

  auth_token = "TIdAao6sd6waZ6NpiC60RZ2nRqYf7C3b"

  multi_az_enabled = true

  additional_cluster_security_group_ingress_rules = [
    {
      cidr_blocks              = ["10.113.0.0/16"]
      description              = "allow internal to connect EC"
      from_port                = 6379
      protocol                 = "tcp"
      source_security_group_id = ""
      to_port                  = 6379
    }
  ]

  snapshot_config = {
    snapshot_retention_limit = 3
    snapshot_window          = "03:00-05:00"
  }

  tags = var.custom_tags

  is_enable_default_alarms = true

  custom_elasticache_alarms_configure = {
    cpu_utilization_too_high = {
      metric_name         = "EngineCPUUtilization"
      statistic           = "Average"
      comparison_operator = ">="
      threshold           = "85"
      period              = "300"
      evaluation_periods  = "1"
    }
  }
}

# Valkey traditional cluster for testing
module "valkey_traditional" {
  source = "../../"

  prefix      = var.prefix
  environment = var.environment
  name        = "valkey-test"

  cache_type = "valkey"

  vpc_config = {
    vpc_id          = module.vpc.vpc_id
    private_subnets = module.vpc.private_subnet_ids
  }

  redis_cluster_config = {
    port           = 6379,
    instance_type  = "cache.t3.micro",
    engine_version = "7.2",
    node_count     = 2
  }

  auth_token = "TIdAao6sd6waZ6NpiC60RZ2nRqYf7C3b"

  multi_az_enabled = true

  snapshot_config = {
    snapshot_retention_limit = 2
    snapshot_window          = "04:00-06:00"
  }

  tags = var.custom_tags

  is_enable_default_alarms = true
}

# Redis Serverless for testing
module "redis_serverless" {
  source = "../../"

  prefix      = var.prefix
  environment = var.environment
  name        = "redis-sless"

  cache_type = "redis-serverless"

  vpc_config = {
    vpc_id          = module.vpc.vpc_id
    private_subnets = module.vpc.private_subnet_ids
  }

  serverless_config = {
    engine_version = "7.0"
    description    = "Redis serverless cache for testing"
    cache_usage_limits = {
      data_storage = {
        maximum = 5
        unit    = "GB"
      }
      ecpu_per_second = {
        maximum = 2500
      }
    }
    daily_snapshot_time      = "03:30"
    snapshot_retention_limit = 1
  }

  tags = var.custom_tags

  is_enable_default_alarms = true
}

# Valkey Serverless for testing
module "valkey_serverless" {
  source = "../../"

  prefix      = var.prefix
  environment = var.environment
  name        = "valkey-sless"

  cache_type = "valkey-serverless"

  vpc_config = {
    vpc_id          = module.vpc.vpc_id
    private_subnets = module.vpc.private_subnet_ids
  }

  serverless_config = {
    engine_version = "7.2"
    description    = "Valkey serverless cache for testing"
    cache_usage_limits = {
      data_storage = {
        maximum = 3
        unit    = "GB"
      }
      ecpu_per_second = {
        maximum = 1500
      }
    }
    daily_snapshot_time      = "04:30"
    snapshot_retention_limit = 1
  }

  tags = var.custom_tags

  is_enable_default_alarms = true
}

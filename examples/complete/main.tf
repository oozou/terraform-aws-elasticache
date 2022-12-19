module "redis" {
  source = "../../"

  prefix      = var.prefix
  environment = var.environment
  name        = "redis"

  vpc_config = {
    vpc_id          = module.vpc.vpc_id
    private_subnets = module.vpc.database_subnet_ids
  }

  redis_cluster_config = {
    port           = 6379,
    instance_type  = "cache.t3.micro",
    engine_version = "6.x",
    node_count     = 1
  }

  auth_token = "TIdAao6sd6waZ6NpiC60RZ2nRqYf7C3b"

  multi_az_enabled = false

  additional_cluster_security_group_ingress_rules = [
    {
      cidr_blocks              = ["10.113.0.0/16"]
      description              = "allow internal to connect EC"
      from_port                = 6379
      is_cidr                  = true
      is_sg                    = false
      protocol                 = "tcp"
      source_security_group_id = ""
      to_port                  = 6379
    }
  ]
  snapshot_config = {
    snapshot_retention_limit = 0
    snapshot_window          = "03:00-05:00"
  }

  tags = var.custom_tags

  is_enable_default_alarms = true
}

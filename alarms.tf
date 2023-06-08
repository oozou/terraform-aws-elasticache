module "custom_elasticache_alarms" {
  source  = "oozou/cloudwatch-alarm/aws"
  version = "2.0.0"

  for_each   = var.custom_elasticache_alarms_configure
  depends_on = [aws_elasticache_replication_group.elasticache]

  prefix      = var.prefix
  environment = var.environment
  name        = format("%s-%s-alarm", local.service_name, each.key)

  alarm_description = format(
    "%s's %s %s %s in period %ss with %s datapoint",
    lookup(each.value, "metric_name", null),
    lookup(each.value, "statistic", "Average"),
    lookup(each.value, "comparison_operator", null),
    lookup(each.value, "threshold", null),
    lookup(each.value, "period", 600),
    lookup(each.value, "evaluation_periods", 1)
  )

  comparison_operator = local.comparison_operators[lookup(each.value, "comparison_operator", null)]
  evaluation_periods  = lookup(each.value, "evaluation_periods", 1)
  metric_name         = lookup(each.value, "metric_name", null)
  namespace           = "AWS/ElastiCache"
  period              = lookup(each.value, "period", 600)
  statistic           = lookup(each.value, "statistic", "Average")
  threshold           = lookup(each.value, "threshold", null)

  dimensions = {
    CacheClusterId = aws_elasticache_replication_group.elasticache.global_replication_group_id
  }

  alarm_actions = lookup(each.value, "alarm_actions", null)
  ok_actions    = lookup(each.value, "ok_actions", null)

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "redis_cpu_alarm" {
  count               = var.is_enable_default_alarms ? 1 : 0
  alarm_name          = format("%s-%s-alarm", local.service_name, "redis_high_CPU")
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "600"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This alarm will trigger if the Redis cluster's cpu usage is too high"
  alarm_actions       = var.default_alarm_actions
  ok_actions          = var.default_ok_actions

  dimensions = {
    CacheClusterId = aws_elasticache_replication_group.elasticache.global_replication_group_id
  }
  depends_on = [aws_elasticache_replication_group.elasticache]
}

resource "aws_cloudwatch_metric_alarm" "redis_memory_alarm" {
  count               = var.is_enable_default_alarms ? 1 : 0
  alarm_name          = format("%s-%s-alarm", local.service_name, "redis_high_memory")
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = "600"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This alarm will trigger if the Redis cluster's memory usage is too high"
  alarm_actions       = var.default_alarm_actions
  ok_actions          = var.default_ok_actions

  dimensions = {
    CacheClusterId = aws_elasticache_replication_group.elasticache.global_replication_group_id
  }
  depends_on = [aws_elasticache_replication_group.elasticache]
}


# Security group for the cluster
resource "aws_security_group" "elasticache" {
  name        = "${local.service_name}-ec-sg"
  description = "Security group for the elasticache cluster"
  vpc_id      = var.vpc_config.vpc_id

  tags = merge({
    Name = "${local.service_name}-ec-sg"
  }, local.tags)
}

# Security group rule for incoming redis connections
resource "aws_security_group_rule" "ingress" {
  security_group_id = aws_security_group.elasticache.id
  description       = "Ingress rule for the elasticache cluster security group"
  type              = "ingress"
  from_port         = var.redis_cluster_config.port
  to_port           = var.redis_cluster_config.port
  protocol          = "tcp"

  source_security_group_id = aws_security_group.client.id
}

# Security group for clients
resource "aws_security_group" "client" {
  name        = "${local.service_name}-ec-client-sg"
  description = "Security group for the elasticache redis client"
  vpc_id      = var.vpc_config.vpc_id

  tags = merge({
    Name = "${local.service_name}-ec-client-sg"
  }, local.tags)
}

# Security group rule for outgoing redis connections
resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.client.id
  type              = "egress"
  from_port         = var.redis_cluster_config.port
  to_port           = var.redis_cluster_config.port
  protocol          = "tcp"

  source_security_group_id = aws_security_group.elasticache.id
}


# Additional Security group rule for incoming and outgoing
resource "aws_security_group_rule" "additional_cluster_ingress" {
  count = length(var.additional_cluster_security_group_ingress_rules)

  type                     = "ingress"
  from_port                = var.additional_cluster_security_group_ingress_rules[count.index].from_port
  to_port                  = var.additional_cluster_security_group_ingress_rules[count.index].to_port
  protocol                 = var.additional_cluster_security_group_ingress_rules[count.index].protocol
  cidr_blocks              = length(var.additional_cluster_security_group_ingress_rules[count.index].source_security_group_id) > 0 ? null : var.additional_cluster_security_group_ingress_rules[count.index].cidr_blocks
  source_security_group_id = length(var.additional_cluster_security_group_ingress_rules[count.index].cidr_blocks) > 0 ? null : var.additional_cluster_security_group_ingress_rules[count.index].source_security_group_id
  security_group_id        = aws_security_group.elasticache.id
  description              = var.additional_cluster_security_group_ingress_rules[count.index].description
}

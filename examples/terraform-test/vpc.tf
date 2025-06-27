/* -------------------------------------------------------------------------- */
/*                                     VPC                                    */
/* -------------------------------------------------------------------------- */
module "vpc" {
  source       = "oozou/vpc/aws"
  version      = "1.2.5"
  prefix       = var.prefix
  environment  = var.environment
  account_mode = "spoke"

  cidr              = "10.0.0.0/16"
  public_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets   = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zone = slice(data.aws_availability_zones.available.names, 0, 2)

  is_create_nat_gateway             = true
  is_enable_single_nat_gateway      = true
  is_enable_dns_hostnames           = true
  is_enable_dns_support             = true
  is_create_flow_log                = false
  is_enable_flow_log_s3_integration = false

  tags = var.custom_tags
}
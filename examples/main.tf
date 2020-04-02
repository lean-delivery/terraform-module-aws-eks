provider "aws" {
  region = "us-east-1"
}

# provider for S3 bucket. when the bucket is stored in other region
provider "aws" {
  region = "eu-central-1"
  alias  = "tfstate"
}

module "core" {
  source = "github.com/lean-delivery/tf-module-aws-core?ref=v0.2"

  project            = "eks"
  environment        = "test"
  availability_zones = ["us-east-1b", "us-east-1c"]
  vpc_cidr           = "10.12.0.0/21"
  private_subnets    = ["10.12.0.0/24", "10.12.1.0/24"]
  public_subnets     = ["10.12.2.0/24", "10.12.3.0/24"]

  enable_nat_gateway = "true"
}

module "eks_test" {
  source = "github.com/lean-delivery/tf-module-aws-eks?ref=v1.0"

  project     = "eks"
  environment = "test"

  s3_bucket_name = "aws-eks-s3-bucket"

  cluster_version           = "1.14"
  cluster_enabled_log_types = ["api"]

  vpc_id          = "${module.core.vpc_id}"
  private_subnets = "${module.core.private_subnets}"
  public_subnets  = "${module.core.public_subnets}"

  spot_configuration = [
    {
      instance_type           = "m4.large"
      spot_price              = "0.05"
      asg_max_size            = "4"
      asg_min_size            = "0"
      asg_desired_capacity    = "0"
      additional_kubelet_args = ""
    },
    {
      instance_type           = "m4.xlarge"
      spot_price              = "0.08"
      asg_max_size            = "4"
      asg_min_size            = "1"
      asg_desired_capacity    = "1"
      additional_kubelet_args = ""
    },
    {
      instance_type           = "m4.2xlarge"
      spot_price              = "0.15"
      asg_max_size            = "4"
      asg_min_size            = "0"
      asg_desired_capacity    = "0"
      additional_kubelet_args = ""
    },
  ]

  on_demand_configuration = [
    {
      instance_type           = "m4.xlarge"
      asg_max_size            = "6"
      asg_min_size            = "0"
      asg_desired_capacity    = "0"
      additional_kubelet_args = ""
    },
  ]

  service_on_demand_configuration = [
    {
      instance_type           = "t3.small"
      asg_max_size            = "1"
      asg_min_size            = "1"
      asg_desired_capacity    = "1"
      additional_kubelet_args = ""
    },
  ]

  worker_nodes_ssh_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDmYWeU1Hm+KfNmnOhB1OVh58KVcetUp6URTPB6fEOmIoNpXXpwFNeotjPoyFwwNc6KJ3LtDOo/Gx9SBkx9sSrHZcJVrKXRF/h4fe4nWeuoz0l3e8Toq+UajIXPjtv+mXkUX5LeyWKwInGc9U3BHXhzV8BYz9i1UqPDDvNsmep5gdRukI327Rh1G+kAYuhivvxbrzsIQrLUMjHqTiL25yILHZJ/eCJvcqLBXtxkPJThytVC1WUZ4vKQ5g8Ley6CtEa/7HolH6RlGduHswzqcdjrSMNxXPoSLF0j4cOeRy7MQA3TU4cLBgcmrwGgE5/IjBy3/3e15D3jtu8jX0r+tUR3 user@example.com"
  enable_waf                = true
  create_acm_certificate    = true
  root_domain               = "eks.example.com"
  alb_route53_record        = "eks-test.eks.example.com"
  alternative_domains       = ["*.eks.nrw-nonprod.brb-labs.com"]
  alternative_domains_count = 1
  target_group_port         = "30081"

  cidr_whitelist = [
    {
      type  = "IPV4"
      value = "194.0.0.0/29"
    },
    {
      type  = "IPV4"
      value = "213.0.0.0/24"
    },
  ]

  deploy_ingress_controller     = true
  deploy_external_dns           = true
  enable_container_logs         = true
  container_logs_retention_days = "5"
  enable_monitoring             = true
  monitoring_availability_zone  = "us-east-1c"
}

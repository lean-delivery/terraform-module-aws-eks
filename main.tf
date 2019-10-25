data "aws_region" "current" {}

data "aws_ami" "eks_ami" {
  most_recent = true
  name_regex  = "^amazon-eks-node-${var.cluster_version}-v[0-9]{8}$"
  owners      = ["602401143452"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_cloudwatch_log_group" "container_logs" {
  count = "${ var.enable_container_logs ? 1 : 0 }"

  name              = "${var.project}-${var.environment}-container-logs"
  retention_in_days = "${var.container_logs_retention_days}"

  tags = {
    project     = "${var.project}"
    environment = "${var.environment}"
  }
}

module "eks" {
  source                    = "github.com/terraform-aws-modules/terraform-aws-eks?ref=v4.0.0"
  cluster_name              = "${var.project}-${var.environment}"
  vpc_id                    = "${var.vpc_id}"
  subnets                   = "${var.private_subnets}"
  cluster_enabled_log_types = "${var.cluster_enabled_log_types}"
  cluster_version           = "${var.cluster_version}"
  local_exec_interpreter    = "${var.local_exec_interpreter}"

  worker_groups = [
    {
      asg_desired_capacity = "0"
      asg_max_size         = "0"
      asg_min_size         = "0"
    },
  ]

  tags = {
    project     = "${var.project}"
    environment = "${var.environment}"
  }
}

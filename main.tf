locals {
  default_tags = {
    Name        = "${var.project}-${var.environment}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

module "Cluster" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "${var.project}-${var.environment}"
  vpc_id       = "${var.vpc_id}"
  subnets      = "${var.subnets_id}"

  worker_groups = [
    {
      ami_id                        = "${var.ami_id}"
      asg_desired_capacity          = "${var.asg_desired_capacity}"
      asg_max_size                  = "${var.asg_max_size}"
      asg_min_size                  = "${var.asg_min_size}"
      instance_type                 = "${var.instance_type}"
      spot_price                    = "${var.spot_price}"
      placement_tenancy             = "${var.placement_tenancy}"
      root_volume_size              = "${var.root_volume_size}"
      root_volume_type              = "${var.root_volume_type}"
      root_iops                     = "${var.root_iops}"
      key_name                      = "${var.key_name}"
      pre_userdata                  = "${var.pre_userdata}"
      additional_userdata           = "${var.additional_userdata}"
      ebs_optimized                 = "${var.ebs_optimized}"
      enable_monitoring             = "${var.enable_monitoring}"
      public_ip                     = "${var.public_ip}"
      kubelet_extra_args            = "${var.kubelet_extra_args}"
      autoscaling_enabled           = "${var.autoscaling_enabled}"
      additional_security_group_ids = "${var.additional_security_group_ids}"
      protect_from_scale_in         = "${var.protect_from_scale_in}"
      suspended_processes           = "${var.suspended_processes}"
      target_group_arns             = "${var.target_group_arns}"
    },
  ]

  tags = {
    Environment = "${var.environment}"
  }
}

module "AS_Polisys" {
  source                     = "AS_policys/"
  autoscaling_group_name     = "${element(module.Cluster.workers_asg_names, 0)}"
  policy_name                = "${var.project}-${var.environment}"
  SimpleScaling_policys      = "${var.SimpleScaling_policys}"
  SimpleAlarmScaling_policys = "${var.SimpleAlarmScaling_policys}"
  StepScaling_policys        = "${var.StepScaling_policys}"
  TargetTracking_policys     = "${var.TargetTracking_policys}"
}

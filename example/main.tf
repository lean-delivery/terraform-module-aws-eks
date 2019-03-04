module "Cluster" {
  source        = "tf-module-aws-eks/"
  ami_id        = "ami-01e08d22b9439c15a"
  vpc_id        = "vpc-49fb682f"
  subnets_id    = ["subnet-8d79a2eb", "subnet-938b23db", "subnet-ecfc19b6"]
  instance_type = "m4.large"
  asg_max_size  = "10"
  spot_price    = "0.05"

  SimpleAlarmScaling_policys = [
    {
      estimated_instance_warmup = ""
      adjustment_type           = "ChangeInCapacity"
      policy_type               = "SimpleScaling"
      cooldown                  = "300"
      scaling_adjustment        = "0"
      alarm_name                = "alarm"
      alarm_comparison_operator = "GreaterThanOrEqualToThreshold"
      alarm_evaluation_periods  = "2"
      alarm_metric_name         = "CPUUtilization"
      alarm_period              = "120"
      alarm_threshold           = "80"
      alarm_description         = "This metric monitors ec2 cpu utilization"
    },
    {
      estimated_instance_warmup = ""
      adjustment_type           = "ExactCapacity"
      policy_type               = "SimpleScaling"
      cooldown                  = "250"
      scaling_adjustment        = "0"
      alarm_name                = "alarm"
      alarm_comparison_operator = "GreaterThanOrEqualToThreshold"
      alarm_evaluation_periods  = "2"
      alarm_metric_name         = "CPUUtilization"
      alarm_period              = "180"
      alarm_threshold           = "90"
      alarm_description         = "This metric monitors ec2 cpu utilization"
    },
  ]

  SimpleScaling_policys = [
    {
      estimated_instance_warmup = ""
      adjustment_type           = "ChangeInCapacity"
      policy_type               = "SimpleScaling"
      cooldown                  = "300"
      scaling_adjustment        = "0"
    },
  ]
}

output "cluster_certificate_authority_data" {
  value = "${module.Cluster.cluster_certificate_authority_data}"
}

output "cluster_endpoint" {
  value = "${module.Cluster.cluster_endpoint}"
}

output "cluster_id" {
  value = "${module.Cluster.cluster_id}"
}

output "cluster_security_group_id" {
  value = "${module.Cluster.cluster_security_group_id}"
}

output "cluster_version" {
  value = "${module.Cluster.cluster_version}"
}

output "config_map_aws_auth" {
  value = "${module.Cluster.config_map_aws_auth}"
}

output "kubeconfig" {
  value = "${module.Cluster.kubeconfig}"
}

output "worker_iam_role_arn" {
  value = "${module.Cluster.worker_iam_role_arn}"
}

output "worker_iam_role_name" {
  value = "${module.Cluster.worker_iam_role_name}"
}

output "worker_security_group_id" {
  value = "${module.Cluster.worker_security_group_id}"
}

output "workers_asg_arns" {
  value = "${module.Cluster.workers_asg_arns}"
}

output "workers_asg_names" {
  value = "${module.Cluster.workers_asg_names}"
}

output "simpleAlarm_id" {
  value = "${module.Cluster.simpleAlarm_id}"
}

output "stepAlarm_id" {
  value = "${module.Cluster.stepAlarm_id}"
}

output "SimpleScaling_ASG_policy_arn" {
  value = "${module.Cluster.SimpleScaling_ASG_policy_arn}"
}

output "SimpleAlarmScaling_ASG_policy_arn" {
  value = "${module.Cluster.SimpleAlarmScaling_ASG_policy_arn}"
}

output "StepScaling_ASG_policy_arn" {
  value = "${module.Cluster.StepScaling_ASG_policy_arn}"
}

output "TargetTracking_ASG_policy_arn" {
  value = "${module.Cluster.TargetTracking_ASG_policy_arn}"
}

output "SimpleScaling_ASG_policy_name" {
  value = "${module.Cluster.SimpleScaling_ASG_policy_name}"
}

output "SimpleAlarmScaling_ASG_policy_name" {
  value = "${module.Cluster.SimpleAlarmScaling_ASG_policy_name}"
}

output "StepScaling_ASG_policy_name" {
  value = "${module.Cluster.StepScaling_ASG_policy_name}"
}

output "TargetTracking_ASG_policy_name" {
  value = "${module.Cluster.TargetTracking_ASG_policy_name}"
}

output "SimpleScaling_ASG_policy_adjustment_type" {
  value = "${module.Cluster.SimpleScaling_ASG_policy_adjustment_type}"
}

output "SimpleAlarmScaling_ASG_policy_adjustment_type" {
  value = "${module.Cluster.SimpleAlarmScaling_ASG_policy_adjustment_type}"
}

output "StepScaling_ASG_policy_adjustment_type" {
  value = "${module.Cluster.StepScaling_ASG_policy_adjustment_type}"
}

output "TargetTracking_ASG_policy_adjustment_type" {
  value = "${module.Cluster.TargetTracking_ASG_policy_adjustment_type}"
}

output "SimpleScaling_ASG_policy_group_name" {
  value = "${module.Cluster.SimpleScaling_ASG_policy_group_name}"
}

output "SimpleAlarmScaling_ASG_policy_group_name" {
  value = "${module.Cluster.SimpleAlarmScaling_ASG_policy_group_name}"
}

output "StepScaling_ASG_policy_group_name" {
  value = "${module.Cluster.StepScaling_ASG_policy_group_name}"
}

output "TargetTracking_ASG_policy_group_name" {
  value = "${module.Cluster.TargetTracking_ASG_policy_group_name}"
}

output "SimpleScaling_ASG_policy_policy_type" {
  value = "${module.Cluster.SimpleScaling_ASG_policy_policy_type}"
}

output "SimpleAlarmScaling_ASG_policy_policy_type" {
  value = "${module.Cluster.SimpleAlarmScaling_ASG_policy_policy_type}"
}

output "StepScaling_ASG_policy_policy_type" {
  value = "${module.Cluster.StepScaling_ASG_policy_policy_type}"
}

output "TargetTracking_ASG_policy_policy_type" {
  value = "${module.Cluster.TargetTracking_ASG_policy_policy_type}"
}

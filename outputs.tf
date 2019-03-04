output "cluster_certificate_authority_data" {
  value       = "${module.Cluster.cluster_certificate_authority_data}"
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster"
}

output "cluster_endpoint" {
  value       = "${module.Cluster.cluster_endpoint}"
  description = "The endpoint for your EKS Kubernetes API"
}

output "cluster_id" {
  value       = "${module.Cluster.cluster_id}"
  description = "The name/id of the EKS cluster"
}

output "cluster_security_group_id" {
  value       = "${module.Cluster.cluster_security_group_id}"
  description = "Security group ID attached to the EKS cluster"
}

output "cluster_version" {
  value       = "${module.Cluster.cluster_version}"
  description = "The Kubernetes server version for the EKS cluster"
}

output "config_map_aws_auth" {
  value       = "${module.Cluster.config_map_aws_auth}"
  description = "A kubernetes configuration to authenticate to this EKS cluster"
}

output "kubeconfig" {
  value       = "${module.Cluster.kubeconfig}"
  description = "kubectl config file contents for this EKS cluster"
}

output "worker_iam_role_arn" {
  value       = "${module.Cluster.worker_iam_role_arn}"
  description = "default IAM role ARN for EKS worker groups"
}

output "worker_iam_role_name" {
  value       = "${module.Cluster.worker_iam_role_name}"
  description = "default IAM role name for EKS worker groups"
}

output "worker_security_group_id" {
  value       = "${module.Cluster.worker_security_group_id}"
  description = "Security group ID attached to the EKS workers"
}

output "workers_asg_arns" {
  value       = "${module.Cluster.workers_asg_arns}"
  description = "IDs of the autoscaling groups containing workers"
}

output "workers_asg_names" {
  value       = "${module.Cluster.workers_asg_names}"
  description = "Names of the autoscaling groups containing workers"
}

output "simpleAlarm_id" {
  value       = "${module.AS_Polisys.simpleAlarm_id}"
  description = "List of The ID-s of the health check for simpleAlarm_policy_alarm"
}

output "stepAlarm_id" {
  value       = "${module.AS_Polisys.stepAlarm_id}"
  description = "List of The ID-s of the health check for step_policy_alarm"
}

output "SimpleScaling_ASG_policy_arn" {
  value       = "${module.AS_Polisys.SimpleScaling_ASG_policy_arn}"
  description = "List of The ARN assigneds by AWS to the scaling policy for SimpleScaling_ASG_policy"
}

output "SimpleAlarmScaling_ASG_policy_arn" {
  value       = "${module.AS_Polisys.SimpleAlarmScaling_ASG_policy_arn}"
  description = "List of The ARN assigneds by AWS to the scaling policy for SimpleAlarmScaling_ASG_policy"
}

output "StepScaling_ASG_policy_arn" {
  value       = "${module.AS_Polisys.StepScaling_ASG_policy_arn}"
  description = "List of The ARN assigneds by AWS to the scaling policy for StepScaling_ASG_policy"
}

output "TargetTracking_ASG_policy_arn" {
  value       = "${module.AS_Polisys.TargetTracking_ASG_policy_arn}"
  description = "List of The ARN assigneds by AWS to the scaling policy for TargetTracking_ASG_policy"
}

output "SimpleScaling_ASG_policy_name" {
  value       = "${module.AS_Polisys.SimpleScaling_ASG_policy_name}"
  description = "List of The scaling policys name for SimpleScaling_ASG_policy"
}

output "SimpleAlarmScaling_ASG_policy_name" {
  value       = "${module.AS_Polisys.SimpleAlarmScaling_ASG_policy_name}"
  description = "List of The scaling policys name for SimpleAlarmScaling_ASG_policy"
}

output "StepScaling_ASG_policy_name" {
  value       = "${module.AS_Polisys.StepScaling_ASG_policy_name}"
  description = "List of The scaling policys name for StepScaling_ASG_policy"
}

output "TargetTracking_ASG_policy_name" {
  value       = "${module.AS_Polisys.TargetTracking_ASG_policy_name}"
  description = "List of The scaling policys name for TargetTracking_ASG_policy"
}

output "SimpleScaling_ASG_policy_adjustment_type" {
  value       = "${module.AS_Polisys.SimpleScaling_ASG_policy_adjustment_type}"
  description = "List of The scaling policys adjustment type for SimpleScaling_ASG_policy"
}

output "SimpleAlarmScaling_ASG_policy_adjustment_type" {
  value       = "${module.AS_Polisys.SimpleAlarmScaling_ASG_policy_adjustment_type}"
  description = "List of The scaling policys adjustment type for SimpleAlarmScaling_ASG_policy"
}

output "StepScaling_ASG_policy_adjustment_type" {
  value       = "${module.AS_Polisys.StepScaling_ASG_policy_adjustment_type}"
  description = "List of The scaling policys adjustment type for StepScaling_ASG_policy"
}

output "TargetTracking_ASG_policy_adjustment_type" {
  value       = "${module.AS_Polisys.TargetTracking_ASG_policy_adjustment_type}"
  description = "List of The scaling policys adjustment type for TargetTracking_ASG_policy"
}

output "SimpleScaling_ASG_policy_group_name" {
  value       = "${module.AS_Polisys.SimpleScaling_ASG_policy_group_name}"
  description = "List of The scaling policys assigned autoscaling group for SimpleScaling_ASG_policy"
}

output "SimpleAlarmScaling_ASG_policy_group_name" {
  value       = "${module.AS_Polisys.SimpleAlarmScaling_ASG_policy_group_name}"
  description = "List of The scaling policys assigned autoscaling group for SimpleAlarmScaling_ASG_policy"
}

output "StepScaling_ASG_policy_group_name" {
  value       = "${module.AS_Polisys.StepScaling_ASG_policy_group_name}"
  description = "List of The scaling policys assigned autoscaling group for StepScaling_ASG_policy"
}

output "TargetTracking_ASG_policy_group_name" {
  value       = "${module.AS_Polisys.TargetTracking_ASG_policy_group_name}"
  description = "List of The scaling policys assigned autoscaling group for TargetTracking_ASG_policy"
}

output "SimpleScaling_ASG_policy_policy_type" {
  value       = "${module.AS_Polisys.SimpleScaling_ASG_policy_policy_type}"
  description = "List of The scaling policys type for SimpleScaling_ASG_policy"
}

output "SimpleAlarmScaling_ASG_policy_policy_type" {
  value       = "${module.AS_Polisys.SimpleAlarmScaling_ASG_policy_policy_type}"
  description = "List of The scaling policys type for SimpleAlarmScaling_ASG_policy"
}

output "StepScaling_ASG_policy_policy_type" {
  value       = "${module.AS_Polisys.StepScaling_ASG_policy_policy_type}"
  description = "List of The scaling policys type for StepScaling_ASG_policy"
}

output "TargetTracking_ASG_policy_policy_type" {
  value       = "${module.AS_Polisys.TargetTracking_ASG_policy_policy_type}"
  description = "List of The scaling policys type for TargetTracking_ASG_policy"
}

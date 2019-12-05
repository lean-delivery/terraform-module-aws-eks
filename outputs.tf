output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = "${module.eks.cluster_arn}"
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = "${module.eks.cluster_iam_role_name}"
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = "${module.eks.cluster_iam_role_arn}"
}

output "kubeconfig_filename" {
  description = "The filename of the generated kubectl config."
  value       = "${module.eks.kubeconfig_filename}"
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate."
  value       = "${module.eks.cluster_certificate_authority_data}"
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint."
  value       = "${module.eks.cluster_endpoint}"
}

output "cluster_id" {
  description = "EKS cluster id."
  value       = "${module.eks.cluster_id}"
}

output "cluster_security_group_id" {
  description = "EKS cluster security group id."
  value       = "${module.eks.cluster_security_group_id}"
}

output "cluster_version" {
  description = "EKS cluster version."
  value       = "${module.eks.cluster_version}"
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = "${module.eks.config_map_aws_auth}"
}

output "kubeconfig" {
  description = "kubectl config file contents for this EKS cluster."
  value       = "${module.eks.kubeconfig}"
}

output "worker_iam_role_arn" {
  description = "IAM role ARN for EKS worker groups."
  value       = "${module.eks.worker_iam_role_arn}"
}

output "worker_iam_role_name" {
  description = " IAM role name for EKS worker groups."
  value       = "${module.eks.worker_iam_role_name}"
}

output "worker_security_group_id" {
  description = "Security group ID attached to the EKS workers."
  value       = "${module.eks.worker_security_group_id}"
}

output "iam_instance_profile_name" {
  description = "IAM instance profile name for EKS worker nodes."
  value       = "${aws_iam_instance_profile.worker-instance-profile.name}"
}

output "ssh_key_name" {
  description = "SSH key name for worker nodes."
  value       = ["${aws_key_pair.worker_ssh_key_pair.*.key_name}"]
}

output "aws_launch_template_spot_asg_names" {
  description = "Launch configurations names for EKS spot worker nodes."
  value       = ["${aws_launch_template.spot-asg.*.name}"]
}

output "spot_asg_names" {
  description = "EKS spot worker nodes ASGs names."
  value       = ["${aws_autoscaling_group.spot-asg.*.name}"]
}

output "spot_asg_ids" {
  description = "EKS spot worker nodes ASGs IDs."
  value       = ["${aws_autoscaling_group.spot-asg.*.id}"]
}

output "spot_asg_arns" {
  description = "EKS spot worker nodes ASGs arns."
  value       = ["${aws_autoscaling_group.spot-asg.*.arn}"]
}

output "launch_configuration_on_demand_asg_names" {
  description = "Launch configuration name for EKS on-demand worker nodes."
  value       = ["${aws_launch_configuration.on-demand-asg.*.name}"]
}

output "on_demand_asg_names" {
  description = "EKS on-demand worker nodes ASGs names."
  value       = ["${aws_autoscaling_group.on-demand-asg.*.name}"]
}

output "on_demand_asg_ids" {
  description = "EKS on-demand worker nodes ASGs IDs."
  value       = ["${aws_autoscaling_group.on-demand-asg.*.id}"]
}

output "on_demand_asg_arns" {
  description = "EKS on-demand worker nodes ASGs arns."
  value       = ["${aws_autoscaling_group.on-demand-asg.*.arn}"]
}

output "launch_configuration_service_on_demand_asg_names" {
  description = "Launch configuration name for EKS non-scalable on-demand worker nodes."
  value       = ["${aws_launch_configuration.service.*.name}"]
}

output "service_on_demand_asg_names" {
  description = "EKS non-scalable on-demand worker nodes ASGs names."
  value       = ["${aws_autoscaling_group.service-on-demand-asg.*.name}"]
}

output "service_on_demand_asg_ids" {
  description = "EKS non-scalable on-demand worker nodes ASGs IDs."
  value       = ["${aws_autoscaling_group.service-on-demand-asg.*.id}"]
}

output "service_on_demand_asg_arns" {
  description = "EKS non-scalable on-demand worker nodes ASGs arns."
  value       = ["${aws_autoscaling_group.service-on-demand-asg.*.arn}"]
}

output "path_to_manifests" {
  description = "Path to rendered manifests for EKS deployments."
  value       = "${path.root}/manifests_rendered"
}

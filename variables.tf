variable "project" {
  description = "Project name is used to identify resources"
  type        = "string"
  default     = "test"
}

variable "environment" {
  description = "Environment name is used to identify resources"
  type        = "string"
  default     = "env"
}

variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed"
  type        = "string"
}

variable "subnets_id" {
  description = "A list of subnets to place the EKS cluster and workers within"
  type        = "list"
}

variable "ami_id" {
  description = "AMI ID for the eks workers."
  type        = "string"
}

variable "asg_desired_capacity" {
  description = "Desired worker capacity in the autoscaling group."
  type        = "string"
  default     = "1"
}

variable "asg_min_size" {
  description = "Minimum worker capacity in the autoscaling group."
  type        = "string"
  default     = "1"
}

variable "placement_tenancy" {
  description = "The tenancy of the instance. Valid values are default or dedicated."
  type        = "string"
  default     = ""
}

variable "root_volume_size" {
  description = "root volume size of workers instances."
  type        = "string"
  default     = "100"
}

variable "root_volume_type" {
  description = "root volume type of workers instances can be standard gp2 or io1"
  type        = "string"
  default     = "gp2"
}

variable "root_iops" {
  description = "The amount of provisioned IOPS. This must be set with a volume_type of io1."
  type        = "string"
  default     = "0"
}

variable "key_name" {
  description = "The key name that should be used for the instances in the autoscaling group"
  type        = "string"
  default     = ""
}

variable "pre_userdata" {
  description = "userdata to pre-append to the default userdata."
  type        = "string"
  default     = ""
}

variable "additional_userdata" {
  description = "userdata to append to the default userdata."
  type        = "string"
  default     = ""
}

variable "ebs_optimized" {
  description = "sets whether to use ebs optimization on supported types."
  default     = true
}

variable "enable_monitoring" {
  description = "Enables/disables detailed monitoring."
  default     = true
}

variable "public_ip" {
  description = "Associate a public ip address with a worker"
  default     = false
}

variable "kubelet_extra_args" {
  description = "This string is passed directly to kubelet if set. Useful for adding labels or taints."
  type        = "string"
  default     = ""
}

variable "autoscaling_enabled" {
  description = "Sets whether policy and matching tags will be added to allow autoscaling."
  default     = true
}

variable "additional_security_group_ids" {
  description = "A comma delimited list of additional security group ids to include in worker launch config"
  type        = "string"
  default     = ""
}

variable "protect_from_scale_in" {
  description = "Prevent AWS from scaling in, so that cluster-autoscaler is solely responsible."
  default     = false
}

variable "suspended_processes" {
  description = "A comma delimited string of processes to to suspend. i.e. AZRebalance HealthCheck ReplaceUnhealthy"
  type        = "string"
  default     = ""
}

variable "target_group_arns" {
  description = "A comma delimited list of ALB target group ARNs to be associated to the ASG"
  type        = "string"
  default     = ""
}

variable "instance_type" {
  description = "Size of the workers instances what will be used in EKS-cluster"
  type        = "string"
  default     = "m4.large"
}

variable "asg_max_size" {
  description = "Maximum worker capacity in in cluster"
  type        = "string"
  default     = "5"
}

variable "spot_price" {
  description = "Cost of spot instance. Value 1 equals one dollar. 0.01 equals one cent. Set this variable if you want run cluster on spot instances"
  type        = "string"
  default     = "0.1"
}

variable "SimpleScaling_policys" {
  description = "A list of AS-policys. Trigger for scaling ASG. Only policy_type SimpleScaling"
  type        = "list"
  default     = []
}

variable "SimpleAlarmScaling_policys" {
  description = "A list of AS-policys. Trigger for scaling ASG. Only policy_type SimpleScaling"
  type        = "list"
  default     = []
}

variable "StepScaling_policys" {
  description = "A list of AS-policys. Trigger for scaling ASG. Only policy_type StepScaling"
  type        = "list"
  default     = []
}

variable "TargetTracking_policys" {
  description = "A list of AS-policys. Trigger for scaling ASG. Only policy_type TargetTrackingScaling"
  type        = "list"
  default     = []
}

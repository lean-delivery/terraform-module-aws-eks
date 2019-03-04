output "simpleAlarm_id" {
  value       = "${aws_cloudwatch_metric_alarm.simpleAlarm_policy_alarm.*.id}"
  description = "List of The ID-s of the health check for simpleAlarm_policy_alarm"
}

output "stepAlarm_id" {
  value       = "${aws_cloudwatch_metric_alarm.step_policy_alarm.*.id}"
  description = "List of The ID-s of the health check for step_policy_alarm"
}

output "SimpleScaling_ASG_policy_arn" {
  value       = ["${aws_autoscaling_policy.SimpleScaling_ASG_policy.*.arn}"]
  description = "List of The ARN assigneds by AWS to the scaling policy for SimpleScaling_ASG_policy"
}

output "SimpleAlarmScaling_ASG_policy_arn" {
  value       = ["${aws_autoscaling_policy.SimpleAlarmScaling_ASG_policy.*.arn}"]
  description = "List of The ARN assigneds by AWS to the scaling policy for SimpleAlarmScaling_ASG_policy"
}

output "StepScaling_ASG_policy_arn" {
  value       = ["${aws_autoscaling_policy.StepScaling_ASG_policy.*.arn}"]
  description = "List of The ARN assigneds by AWS to the scaling policy for StepScaling_ASG_policy"
}

output "TargetTracking_ASG_policy_arn" {
  value       = ["${aws_autoscaling_policy.TargetTracking_ASG_policy.*.arn}"]
  description = "List of The ARN assigneds by AWS to the scaling policy for TargetTracking_ASG_policy"
}

output "SimpleScaling_ASG_policy_name" {
  value       = ["${aws_autoscaling_policy.SimpleScaling_ASG_policy.*.name}"]
  description = "List of The scaling policys name for SimpleScaling_ASG_policy"
}

output "SimpleAlarmScaling_ASG_policy_name" {
  value       = ["${aws_autoscaling_policy.SimpleAlarmScaling_ASG_policy.*.name}"]
  description = "List of The scaling policys name for SimpleAlarmScaling_ASG_policy"
}

output "StepScaling_ASG_policy_name" {
  value       = ["${aws_autoscaling_policy.StepScaling_ASG_policy.*.name}"]
  description = "List of The scaling policys name for StepScaling_ASG_policy"
}

output "TargetTracking_ASG_policy_name" {
  value       = ["${aws_autoscaling_policy.TargetTracking_ASG_policy.*.name}"]
  description = "List of The scaling policys name for TargetTracking_ASG_policy"
}

output "SimpleScaling_ASG_policy_adjustment_type" {
  value       = ["${aws_autoscaling_policy.SimpleScaling_ASG_policy.*.adjustment_type}"]
  description = "List of The scaling policys adjustment type for SimpleScaling_ASG_policy"
}

output "SimpleAlarmScaling_ASG_policy_adjustment_type" {
  value       = ["${aws_autoscaling_policy.SimpleAlarmScaling_ASG_policy.*.adjustment_type}"]
  description = "List of The scaling policys adjustment type for SimpleAlarmScaling_ASG_policy"
}

output "StepScaling_ASG_policy_adjustment_type" {
  value       = ["${aws_autoscaling_policy.StepScaling_ASG_policy.*.adjustment_type}"]
  description = "List of The scaling policys adjustment type for StepScaling_ASG_policy"
}

output "TargetTracking_ASG_policy_adjustment_type" {
  value       = ["${aws_autoscaling_policy.TargetTracking_ASG_policy.*.adjustment_type}"]
  description = "List of The scaling policys adjustment type for TargetTracking_ASG_policy"
}

output "SimpleScaling_ASG_policy_group_name" {
  value       = ["${aws_autoscaling_policy.SimpleScaling_ASG_policy.*.autoscaling_group_name}"]
  description = "List of The scaling policys assigned autoscaling group for SimpleScaling_ASG_policy"
}

output "SimpleAlarmScaling_ASG_policy_group_name" {
  value       = ["${aws_autoscaling_policy.SimpleAlarmScaling_ASG_policy.*.autoscaling_group_name}"]
  description = "List of The scaling policys assigned autoscaling group for SimpleAlarmScaling_ASG_policy"
}

output "StepScaling_ASG_policy_group_name" {
  value       = ["${aws_autoscaling_policy.StepScaling_ASG_policy.*.autoscaling_group_name}"]
  description = "List of The scaling policys assigned autoscaling group for StepScaling_ASG_policy"
}

output "TargetTracking_ASG_policy_group_name" {
  value       = ["${aws_autoscaling_policy.TargetTracking_ASG_policy.*.autoscaling_group_name}"]
  description = "List of The scaling policys assigned autoscaling group for TargetTracking_ASG_policy"
}

output "SimpleScaling_ASG_policy_policy_type" {
  value       = ["${aws_autoscaling_policy.SimpleScaling_ASG_policy.*.policy_type}"]
  description = "List of The scaling policys type for SimpleScaling_ASG_policy"
}

output "SimpleAlarmScaling_ASG_policy_policy_type" {
  value       = ["${aws_autoscaling_policy.SimpleAlarmScaling_ASG_policy.*.policy_type}"]
  description = "List of The scaling policys type for SimpleAlarmScaling_ASG_policy"
}

output "StepScaling_ASG_policy_policy_type" {
  value       = ["${aws_autoscaling_policy.StepScaling_ASG_policy.*.policy_type}"]
  description = "List of The scaling policys type for StepScaling_ASG_policy"
}

output "TargetTracking_ASG_policy_policy_type" {
  value       = ["${aws_autoscaling_policy.TargetTracking_ASG_policy.*.policy_type}"]
  description = "List of The scaling policys type for TargetTracking_ASG_policy"
}

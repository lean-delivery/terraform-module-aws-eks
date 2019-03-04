# AS_policys

The module allows you to set list of AutoScaling-Policy with Cloudwatch metric alarms for AutoScaling-group for EKS cluster in AWS. Automatically will be created:

 * AutoScaling-Policys
 * Cloudwatch metric alarms

WARNING: Different types of AutoScaling-Policy may conflict with each other.



## Usage example

```hcl
module "AS_Polisys" {
  source = "AS_policys/"
  autoscaling_group_name = "my_autoscaling_group"

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
  }]

  SimpleScaling_policys = [
  {
    estimated_instance_warmup = ""
    adjustment_type           = "ChangeInCapacity"
    policy_type               = "SimpleScaling"
    cooldown                  = "300"
    scaling_adjustment        = "0"
  }]
}

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| autoscaling_group_name | AutoScaling-Group for which autoscaling_policy will be created | string | n/a | yes |
| policy_name | name for policy for autoscaling group | string | - | Yes
| SimpleScaling_policys | List of policys with type "SimpleScaling" without alarms | list | [] | no |
| SimpleAlarmScaling_policys| List of policys with type "SimpleScaling" with alarms | list | [] | no |
| StepScaling_policys | List of policys with type "StepScaling" (only with alarms) | list | [] | no |
| TargetTracking_policys | List of policys with type "TargetTracking" (only without alarm) | list | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| simpleAlarm_id | List of The ID-s of the health check for simpleAlarm_policy_alarm |
| stepAlarm_id | List of The ID-s of the health check for step_policy_alarm |
| SimpleScaling_ASG_policy_arn | List of The ARN assigneds by AWS to the scaling policy for SimpleScaling_ASG_policy |
| SimpleAlarmScaling_ASG_policy_arn | List of The ARN assigneds by AWS to the scaling policy for SimpleAlarmScaling_ASG_policy |
| StepScaling_ASG_policy_arn | List of The ARN assigneds by AWS to the scaling policy for StepScaling_ASG_policy |
| TargetTracking_ASG_policy_arn | List of The ARN assigneds by AWS to the scaling policy for TargetTracking_ASG_policy |
| SimpleScaling_ASG_policy_name | List of The scaling policys name for SimpleScaling_ASG_policy |
| SimpleAlarmScaling_ASG_policy_name | List of The scaling policys name for SimpleAlarmScaling_ASG_policy |
| StepScaling_ASG_policy_name | List of The scaling policys name for StepScaling_ASG_policy |
| TargetTracking_ASG_policy_name | List of The scaling policys name for TargetTracking_ASG_policy |
| SimpleScaling_ASG_policy_adjustment_type | List of The scaling policys adjustment type for SimpleScaling_ASG_policy |
| SimpleAlarmScaling_ASG_policy_adjustment_type | List of The scaling policys adjustment type for SimpleAlarmScaling_ASG_policy |
| StepScaling_ASG_policy_adjustment_type | List of The scaling policys adjustment type for StepScaling_ASG_policy |
| TargetTracking_ASG_policy_adjustment_type | List of The scaling policys adjustment type for TargetTracking_ASG_policy |
| SimpleScaling_ASG_policy_group_name | List of The scaling policys assigned autoscaling group for SimpleScaling_ASG_policy |
| SimpleAlarmScaling_ASG_policy_group_name | List of The scaling policys assigned autoscaling group for SimpleAlarmScaling_ASG_policy |
| StepScaling_ASG_policy_group_name | List of The scaling policys assigned autoscaling group for StepScaling_ASG_policy |
| TargetTracking_ASG_policy_group_name | List of The scaling policys assigned autoscaling group for TargetTracking_ASG_policy |
| SimpleScaling_ASG_policy_policy_type | List of The scaling policys type for SimpleScaling_ASG_policy |
| SimpleAlarmScaling_ASG_policy_policy_type | List of The scaling policys type for SimpleAlarmScaling_ASG_policy |
| StepScaling_ASG_policy_policy_type | List of The scaling policys type for StepScaling_ASG_policy |
| TargetTracking_ASG_policy_policy_type | List of The scaling policys type for TargetTracking_ASG_policy |

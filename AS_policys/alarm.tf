resource "aws_cloudwatch_metric_alarm" "simpleAlarm_policy_alarm" {
  count               = "${length(var.SimpleAlarmScaling_policys)}"
  alarm_name          = "${lookup( var.SimpleAlarmScaling_policys[count.index], "alarm_name"               )}-${count.index}"
  comparison_operator = "${lookup( var.SimpleAlarmScaling_policys[count.index], "alarm_comparison_operator")}"
  evaluation_periods  = "${lookup( var.SimpleAlarmScaling_policys[count.index], "alarm_evaluation_periods" )}"
  metric_name         = "${lookup( var.SimpleAlarmScaling_policys[count.index], "alarm_metric_name"        )}"
  period              = "${lookup( var.SimpleAlarmScaling_policys[count.index], "alarm_period"             )}"
  threshold           = "${lookup( var.SimpleAlarmScaling_policys[count.index], "alarm_threshold"          )}"
  alarm_description   = "${lookup( var.SimpleAlarmScaling_policys[count.index], "alarm_description"        )}"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  alarm_actions       = ["${element(aws_autoscaling_policy.SimpleScaling_ASG_policy.*.arn, count.index)}"]

  dimensions = {
    AutoScalingGroupName = "${var.autoscaling_group_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "step_policy_alarm" {
  count               = "${length(var.StepScaling_policys)}"
  alarm_name          = "${lookup( var.StepScaling_policys[count.index], "alarm_name"               )}-${count.index}"
  comparison_operator = "${lookup( var.StepScaling_policys[count.index], "alarm_comparison_operator")}"
  evaluation_periods  = "${lookup( var.StepScaling_policys[count.index], "alarm_evaluation_periods" )}"
  metric_name         = "${lookup( var.StepScaling_policys[count.index], "alarm_metric_name"        )}"
  period              = "${lookup( var.StepScaling_policys[count.index], "alarm_period"             )}"
  threshold           = "${lookup( var.StepScaling_policys[count.index], "alarm_threshold"          )}"
  alarm_description   = "${lookup( var.StepScaling_policys[count.index], "alarm_description"        )}"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  alarm_actions       = ["${element(aws_autoscaling_policy.StepScaling_ASG_policy.*.arn, count.index)}"]

  dimensions = {
    AutoScalingGroupName = "${var.autoscaling_group_name}"
  }
}

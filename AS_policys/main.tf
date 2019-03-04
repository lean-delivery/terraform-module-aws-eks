resource "aws_autoscaling_policy" "SimpleScaling_ASG_policy" {
  count                  = "${length(var.SimpleScaling_policys)}"
  name                   = "SimpleScaling-policy for ${var.policy_name}-autoscaling_group-${count.index}"
  autoscaling_group_name = "${var.autoscaling_group_name}"
  adjustment_type        = "${lookup(var.SimpleScaling_policys[count.index], "adjustment_type")}"
  policy_type            = "${lookup(var.SimpleScaling_policys[count.index], "policy_type")}"
  cooldown               = "${lookup(var.SimpleScaling_policys[count.index], "cooldown")}"
  scaling_adjustment     = "${lookup(var.SimpleScaling_policys[count.index], "scaling_adjustment")}"
}

resource "aws_autoscaling_policy" "SimpleAlarmScaling_ASG_policy" {
  count                  = "${length(var.SimpleAlarmScaling_policys)}"
  name                   = "SimpleAlarmScaling-policy for ${var.policy_name}-autoscaling_group-${count.index}"
  autoscaling_group_name = "${var.autoscaling_group_name}"
  adjustment_type        = "${lookup(var.SimpleAlarmScaling_policys[count.index], "adjustment_type")}"
  policy_type            = "${lookup(var.SimpleAlarmScaling_policys[count.index], "policy_type")}"
  cooldown               = "${lookup(var.SimpleAlarmScaling_policys[count.index], "cooldown")}"
  scaling_adjustment     = "${lookup(var.SimpleAlarmScaling_policys[count.index], "scaling_adjustment")}"
}

resource "aws_autoscaling_policy" "StepScaling_ASG_policy" {
  count                  = "${length(var.StepScaling_policys)}"
  name                   = "StepScaling-policy for ${var.policy_name}-autoscaling_group-${count.index}"
  autoscaling_group_name = "${var.autoscaling_group_name}"
  adjustment_type        = "${lookup(var.StepScaling_policys[count.index], "adjustment_type")}"
  policy_type            = "${lookup(var.StepScaling_policys[count.index], "policy_type")}"

  step_adjustment {
    scaling_adjustment          = "${lookup(var.StepScaling_policys[count.index], "step_adjustment.scaling_adjustment")}"
    metric_interval_lower_bound = "${lookup(var.StepScaling_policys[count.index], "step_adjustment.metric_interval_lower_bound")}"
    metric_interval_upper_bound = "${lookup(var.StepScaling_policys[count.index], "step_adjustment.metric_interval_upper_bound")}"
  }
}

resource "aws_autoscaling_policy" "TargetTracking_ASG_policy" {
  count                  = "${length(var.TargetTracking_policys)}"
  name                   = "TargetTracking-policy for ${var.policy_name}-autoscaling_group-${count.index}"
  autoscaling_group_name = "${var.autoscaling_group_name}"
  adjustment_type        = "${lookup(var.TargetTracking_policys[count.index], "adjustment_type")}"
  policy_type            = "${lookup(var.TargetTracking_policys[count.index], "policy_type")}"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "${lookup(var.TargetTracking_policys[count.index], "predefined_metric_type")}"
    }

    target_value = "${lookup(var.TargetTracking_policys[count.index], "target_value")}"
  }
}

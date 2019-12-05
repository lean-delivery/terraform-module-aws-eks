data "aws_caller_identity" "current" {}

resource "aws_key_pair" "worker_ssh_key_pair" {
  count = "${var.worker_nodes_ssh_key == "" ? 0 : 1}"

  key_name   = "${var.project}-${var.environment}-eks-ssh"
  public_key = "${var.worker_nodes_ssh_key}"
}

locals {
  ssh_key = "${var.worker_nodes_ssh_key == "" ? var.worker_nodes_ssh_key : "${var.project}-${var.environment}-eks-ssh"}"
}

data "template_file" "spot_user_data" {
  count = "${length(var.spot_configuration)}"

  template = "${file("${path.module}/user_data/spot.tpl")}"

  vars = {
    certificate_data        = "${module.eks.cluster_certificate_authority_data}"
    api_endpoint            = "${module.eks.cluster_endpoint}"
    project                 = "${var.project}"
    environment             = "${var.environment}"
    additional_kubelet_args = "${lookup(var.spot_configuration[count.index], "additional_kubelet_args")}"
  }
}

data "template_file" "on_demand_user_data" {
  count = "${length(var.on_demand_configuration)}"

  template = "${file("${path.module}/user_data/on_demand.tpl")}"

  vars = {
    certificate_data        = "${module.eks.cluster_certificate_authority_data}"
    api_endpoint            = "${module.eks.cluster_endpoint}"
    project                 = "${var.project}"
    environment             = "${var.environment}"
    additional_kubelet_args = "${lookup(var.on_demand_configuration[count.index], "additional_kubelet_args")}"
  }
}

data "template_file" "service_on_demand_user_data" {
  count = "${length(var.service_on_demand_configuration)}"

  template = "${file("${path.module}/user_data/service_on_demand.tpl")}"

  vars = {
    certificate_data        = "${module.eks.cluster_certificate_authority_data}"
    api_endpoint            = "${module.eks.cluster_endpoint}"
    project                 = "${var.project}"
    environment             = "${var.environment}"
    additional_kubelet_args = "${lookup(var.service_on_demand_configuration[count.index], "additional_kubelet_args")}"
  }
}

resource "aws_iam_instance_profile" "worker-instance-profile" {
  name = "${var.project}-${var.environment}-worker-instance-profile"
  role = "${module.eks.worker_iam_role_name}"
}

///////////////////SPOT///////////////////
resource "aws_launch_template" "spot-asg" {
  count         = "${length(var.spot_configuration)}"
  name_prefix   = "${var.project}-${var.environment}-spot-${count.index}-${lookup(var.spot_configuration[count.index], "instance_type")}"
  image_id      = "${var.eks_ami == "" ? data.aws_ami.eks_ami.id : var.eks_ami}"
  instance_type = "${lookup(var.spot_configuration[count.index], "instance_type")}"

  iam_instance_profile = {
    name = "${aws_iam_instance_profile.worker-instance-profile.name}"
  }

  vpc_security_group_ids = ["${module.eks.worker_security_group_id}"]
  key_name               = "${local.ssh_key}"
  ebs_optimized          = true

  user_data = "${base64encode(element(data.template_file.spot_user_data.*.rendered, count.index))}"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = "${var.volume_size}"
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "spot-asg" {
  count                     = "${length(var.spot_configuration) * length(var.private_subnets)}"
  name                      = "${var.project}-${var.environment}-spot-asg-${count.index % length(var.private_subnets)}-${lookup(var.spot_configuration[count.index / length(var.private_subnets)], "instance_type")}"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  max_size                  = "${lookup(var.spot_configuration[count.index / length(var.private_subnets)], "asg_max_size")}"
  min_size                  = "${lookup(var.spot_configuration[count.index / length(var.private_subnets)], "asg_min_size")}"
  desired_capacity          = "${lookup(var.spot_configuration[count.index / length(var.private_subnets)], "asg_desired_capacity")}"
  force_delete              = true

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = "${aws_launch_template.spot-asg.*.id[count.index / length(var.private_subnets)]}"
        version            = "$Latest"
      }

      override {
        instance_type = "${lookup(var.spot_configuration[count.index / length(var.private_subnets)], "instance_type")}"
      }

      override {
        instance_type = "${lookup(var.spot_configuration[count.index / length(var.private_subnets)], "additional_instance_type_1")}"
      }

      override {
        instance_type = "${lookup(var.spot_configuration[count.index / length(var.private_subnets)], "additional_instance_type_2")}"
      }
    }

    instances_distribution {
      on_demand_allocation_strategy            = "prioritized"
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "lowest-price"
      spot_max_price                           = "${lookup(var.spot_configuration[count.index / length(var.private_subnets)], "spot_price")}"
    }
  }

  vpc_zone_identifier     = ["${var.private_subnets[count.index % length(var.private_subnets)]}"]
  service_linked_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["desired_capacity"]
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.project}-${var.environment}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/lifecycle"
    value               = "EC2Spot"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-spot-asg-${lookup(var.spot_configuration[count.index / length(var.private_subnets)], "instance_type")}-${count.index % length(var.private_subnets)}"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.project}-${var.environment}"
    value               = ""
    propagate_at_launch = false
  }

  tag {
    key                 = "Project"
    value               = "${var.project}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
    value               = "${var.volume_size}Gi"
    propagate_at_launch = false
  }
}

resource "aws_launch_configuration" "on-demand-asg" {
  count                       = "${length(var.on_demand_configuration)}"
  name_prefix                 = "${var.project}-${var.environment}-on-demand-${count.index}-${lookup(var.on_demand_configuration[count.index], "instance_type")}"
  image_id                    = "${var.eks_ami == "" ? data.aws_ami.eks_ami.id : var.eks_ami}"
  instance_type               = "${lookup(var.on_demand_configuration[count.index], "instance_type")}"
  iam_instance_profile        = "${aws_iam_instance_profile.worker-instance-profile.name}"
  security_groups             = ["${module.eks.worker_security_group_id}"]
  key_name                    = "${local.ssh_key}"
  ebs_optimized               = true
  associate_public_ip_address = false
  user_data                   = "${element(data.template_file.on_demand_user_data.*.rendered, count.index)}"

  root_block_device {
    volume_size           = "${var.volume_size}"
    volume_type           = "gp2"
    iops                  = "0"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "on-demand-asg" {
  count                     = "${length(var.on_demand_configuration) * length(var.private_subnets)}"
  name                      = "${var.project}-${var.environment}-on-demand-asg-${count.index % length(var.private_subnets)}-${lookup(var.on_demand_configuration[count.index / length(var.private_subnets)], "instance_type")}"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  max_size                  = "${lookup(var.on_demand_configuration[count.index / length(var.private_subnets)], "asg_max_size")}"
  min_size                  = "${lookup(var.on_demand_configuration[count.index / length(var.private_subnets)], "asg_min_size")}"
  desired_capacity          = "${lookup(var.on_demand_configuration[count.index / length(var.private_subnets)], "asg_desired_capacity")}"
  force_delete              = true
  target_group_arns         = ["${aws_lb_target_group.alb.arn}"]
  launch_configuration      = "${aws_launch_configuration.on-demand-asg.*.name[count.index / length(var.private_subnets)]}"
  vpc_zone_identifier       = ["${var.private_subnets[count.index % length(var.private_subnets)]}"]
  service_linked_role_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["desired_capacity"]
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-on-demand-asg-${lookup(var.on_demand_configuration[count.index / length(var.private_subnets)], "instance_type")}-${count.index % length(var.private_subnets)}"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.project}-${var.environment}"
    value               = ""
    propagate_at_launch = false
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.project}-${var.environment}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "${var.project}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
    value               = "${var.volume_size}Gi"
    propagate_at_launch = false
  }
}

resource "aws_launch_configuration" "service" {
  count                       = "${length(var.service_on_demand_configuration)}"
  name_prefix                 = "${var.project}-${var.environment}-service-${count.index}-${lookup(var.service_on_demand_configuration[count.index], "instance_type")}"
  image_id                    = "${var.eks_ami == "" ? data.aws_ami.eks_ami.id : var.eks_ami}"
  instance_type               = "${lookup(var.service_on_demand_configuration[count.index], "instance_type")}"
  iam_instance_profile        = "${aws_iam_instance_profile.worker-instance-profile.name}"
  security_groups             = ["${module.eks.worker_security_group_id}"]
  key_name                    = "${local.ssh_key}"
  ebs_optimized               = true
  associate_public_ip_address = false
  user_data                   = "${element(data.template_file.service_on_demand_user_data.*.rendered, count.index)}"

  root_block_device {
    volume_size           = "${var.volume_size}"
    volume_type           = "gp2"
    iops                  = "0"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "service-on-demand-asg" {
  count                     = "${length(var.service_on_demand_configuration) * length(var.private_subnets)}"
  name                      = "${var.project}-${var.environment}-service-on-demand-asg-${lookup(var.service_on_demand_configuration[count.index / length(var.private_subnets)], "instance_type")}-${count.index % length(var.private_subnets)}"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  max_size                  = "${lookup(var.service_on_demand_configuration[count.index / length(var.private_subnets)], "asg_max_size")}"
  min_size                  = "${lookup(var.service_on_demand_configuration[count.index / length(var.private_subnets)], "asg_min_size")}"
  desired_capacity          = "${lookup(var.service_on_demand_configuration[count.index / length(var.private_subnets)], "asg_desired_capacity")}"
  force_delete              = true
  target_group_arns         = ["${aws_lb_target_group.alb.arn}"]
  launch_configuration      = "${aws_launch_configuration.service.*.name[count.index / length(var.private_subnets)]}"
  vpc_zone_identifier       = ["${var.private_subnets[count.index % length(var.private_subnets)]}"]
  service_linked_role_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["desired_capacity"]
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-service-on-demand-${lookup(var.service_on_demand_configuration[count.index / length(var.private_subnets)], "instance_type")}-${count.index / length(var.private_subnets)}"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.project}-${var.environment}"
    value               = ""
    propagate_at_launch = false
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.project}-${var.environment}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "${var.project}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
    value               = "${var.volume_size}Gi"
    propagate_at_launch = false
  }
}

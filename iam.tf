data "aws_iam_policy_document" "external-dns-policy" {
  statement {
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "external-dns-policy" {
  count = "${ var.deploy_external_dns ? 1 : 0 }"

  name   = "${var.project}-${var.environment}-external-dns-policy"
  policy = "${data.aws_iam_policy_document.external-dns-policy.json}"
}

resource "aws_iam_role_policy_attachment" "external-dns-policy" {
  count = "${ var.deploy_external_dns ? 1 : 0 }"

  role       = "${module.eks.worker_iam_role_name}"
  policy_arn = "${aws_iam_policy.external-dns-policy.arn}"
}

data "aws_iam_policy_document" "k8s-autoscaler" {
  statement {
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:DescribeTags",
      "autoscaling:DescribeLaunchConfigurations",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "k8s-autoscaler" {
  name   = "${var.project}-${var.environment}-k8s-autoscaler-policy"
  policy = "${data.aws_iam_policy_document.k8s-autoscaler.json}"
}

resource "aws_iam_role_policy_attachment" "k8s-autoscaler" {
  role       = "${module.eks.worker_iam_role_name}"
  policy_arn = "${aws_iam_policy.k8s-autoscaler.arn}"
}

data "aws_iam_policy_document" "cloudwatch-access" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

resource "aws_iam_policy" "cloudwatch-access" {
  count = "${ var.enable_container_logs ? 1 : 0 }"

  name   = "${var.project}-${var.environment}-cloudwatch-access-policy"
  policy = "${data.aws_iam_policy_document.cloudwatch-access.json}"
}

resource "aws_iam_role_policy_attachment" "cloudwatch-access" {
  count = "${ var.enable_container_logs ? 1 : 0 }"

  role       = "${module.eks.worker_iam_role_name}"
  policy_arn = "${aws_iam_policy.cloudwatch-access.arn}"
}

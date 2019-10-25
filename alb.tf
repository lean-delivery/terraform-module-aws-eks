data "aws_route53_zone" "hosted_zone" {
  name         = "${var.root_domain}"
  private_zone = false
}

module "acm-cert" {
  source = "github.com/lean-delivery/tf-module-aws-acm?ref=v0.3"

  module_enabled = "${var.create_acm_certificate}"

  domain  = "${var.alb_route53_record}"
  zone_id = "${data.aws_route53_zone.hosted_zone.id}"

  alternative_domains_count = "${var.alternative_domains_count}"
  alternative_domains = "${var.alternative_domains}"
}

module "alb-waf" {
  source = "github.com/lean-delivery/tf-module-aws-lb-waf?ref=v0.1"

  module_enabled = "${var.enable_waf}"

  project           = "${var.project}"
  environment       = "${var.environment}"
  load_balancer_arn = "${aws_lb.alb.arn}"
  whitelist         = "${var.cidr_whitelist}"
}

resource "aws_lb_target_group" "alb" {
  name        = "${var.project}-${var.environment}-alb"
  port        = "${var.target_group_port}"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "instance"
  health_check {
    path = "/healthz"
  }
}

resource "aws_security_group" "alb-security-group" {
  name        = "${var.project}-${var.environment}-alb-securiry-group"
  description = "Allow inbound traffic"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

resource "aws_security_group_rule" "this" {
  count = "${length(var.alb_ingress_rules)}"

  type        = "ingress"
  from_port   = "${lookup(var.alb_ingress_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.alb_ingress_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.alb_ingress_rules[count.index], "protocol")}"
  cidr_blocks = ["${lookup(var.alb_ingress_rules[count.index], "cidr_blocks")}"]

  security_group_id = "${aws_security_group.alb-security-group.id}"
}

resource "aws_lb" "alb" {
  name               = "${var.project}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb-security-group.id}","${module.eks.worker_security_group_id}"]
  subnets            = "${var.public_subnets}"

  enable_deletion_protection = false

  tags = {
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

resource "aws_route53_record" "alb-route53-record" {
  zone_id = "${data.aws_route53_zone.hosted_zone.id}"
  name    = "${var.alb_route53_record}"
  type    = "A"

  alias {
    name                   = "${aws_lb.alb.dns_name}"
    zone_id                = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_lb_listener" "redirect_to_https" {
  count             = "${var.create_acm_certificate}"
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  count             = "${var.create_acm_certificate}"
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${module.acm-cert.certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.alb.arn}"
  }
}

resource "aws_lb_listener" "http" {
  count             = "${var.create_acm_certificate ? 0 : 1}"
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.alb.arn}"
  }
}

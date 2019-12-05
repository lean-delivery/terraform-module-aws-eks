resource "null_resource" "eks_cluster" {
  triggers = {
    cluster_id = "${module.eks.cluster_id}"
  }
}

data "aws_subnet" "pvc_subnet" {
  id = "${var.private_subnets[0]}"
}

locals {
  pvc_az = "${var.monitoring_availability_zone == "" ? data.aws_subnet.pvc_subnet.availability_zone : var.monitoring_availability_zone}"
}

resource "null_resource" "check_api" {
  depends_on = ["null_resource.eks_cluster"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
exit_code=1
while [ $exit_code -ne 0 ]; do \
exit_code=$(kubectl get pods --all-namespaces --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename} | echo &?); \
sleep 5; \
done;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

resource "null_resource" "priority_class" {
  depends_on = ["null_resource.check_api"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f manifests/high-priority--deployments-priorityclass.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename};
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

resource "null_resource" "install_tiller" {
  depends_on = ["null_resource.check_api", "aws_autoscaling_group.spot-asg"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f manifests/tiller-rbac.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
helm init --wait --service-account tiller --history-max 10 --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

data "template_file" "ingress_controller_service" {
  template = "${file("${path.module}/manifests_templates/nginx-ingress-service.tpl")}"

  vars = {
    node_port = "${var.target_group_port}"
  }
}

resource "local_file" "ingress_controller_service" {
  count = "${ var.deploy_nginx_ingress ? 1 : 0 }"

  content  = "${data.template_file.ingress_controller_service.rendered}"
  filename = "${path.module}/manifests/nginx-ingress/3-nginx-ingress-service.yaml"
}

resource "null_resource" "deploy_nginx_ingress" {
  count      = "${ var.deploy_nginx_ingress ? 1 : 0 }"
  depends_on = ["null_resource.check_api", "local_file.ingress_controller_service"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f manifests/nginx-ingress/1-namespace.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
kubectl apply -f manifests/nginx-ingress/2-nginx-ingress-rbac-deployment.yaml -f manifests/nginx-ingress/3-nginx-ingress-service.yaml -f manifests/nginx-ingress/4-default-http-backend.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

data "template_file" "external_dns_manifest" {
  template = "${file("${path.module}/manifests_templates/external-dns.tpl")}"

  vars = {
    root_domain = "${var.root_domain}"
    project     = "${var.project}"
    environment = "${var.environment}"
  }
}

resource "local_file" "external_dns_manifest" {
  count = "${ var.deploy_external_dns ? 1 : 0 }"

  content  = "${data.template_file.external_dns_manifest.rendered}"
  filename = "${path.module}/manifests/external_dns.yaml"
}

resource "null_resource" "deploy_external_dns" {
  count      = "${ var.deploy_external_dns ? 1 : 0 }"
  depends_on = ["null_resource.check_api", "local_file.external_dns_manifest"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f manifests/external_dns.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

data "template_file" "cluster_autoscaler_config" {
  template = "${file("${path.module}/manifests_templates/cluster-autoscaler/kubernetes-autoscaler.tpl")}"

  vars = {
    cluster_name = "${var.project}-${var.environment}"
    region       = "${data.aws_region.current.name}"
  }
}

resource "local_file" "cluster_autoscaler_config" {
  content  = "${data.template_file.cluster_autoscaler_config.rendered}"
  filename = "${path.module}/manifests/cluster-autoscaler/kubernetes-autoscaler.yaml"
}

data "template_file" "cluster_autoscaler_priority_configmap" {
  template = "${file("${path.module}/manifests_templates/cluster-autoscaler/autoscaler-priority.tpl")}"

  vars = {
    project     = "${var.project}"
    environment = "${var.environment}"
  }
}

resource "local_file" "cluster_autoscaler_priority_configmap" {
  content  = "${data.template_file.cluster_autoscaler_priority_configmap.rendered}"
  filename = "${path.module}/manifests/cluster-autoscaler/autoscaler-priority.yaml"
}

resource "null_resource" "deploy_cluster_autoscaler" {
  depends_on = ["local_file.cluster_autoscaler_config", "null_resource.priority_class", "local_file.cluster_autoscaler_priority_configmap"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f manifests/cluster-autoscaler/autoscaler-priority.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
kubectl apply -f manifests/cluster-autoscaler/kubernetes-autoscaler.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

resource "null_resource" "deploy_metric_server" {
  depends_on = ["null_resource.check_api"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f manifests/metric-server/ --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

resource "null_resource" "deploy_spot-termination-handler" {
  depends_on = ["null_resource.install_tiller"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
helm install --namespace kube-system --name termination-handler manifests/spot-termination-handler/ --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

data "template_file" "fluentd_config" {
  template = "${file("${path.module}/manifests_templates/fluentd_values.tpl")}"

  vars = {
    region          = "${data.aws_region.current.name}"
    project         = "${var.project}"
    environment     = "${var.environment}"
    iam_worker_role = "${module.eks.worker_iam_role_name}"
  }
}

resource "local_file" "fluentd_config" {
  content  = "${data.template_file.fluentd_config.rendered}"
  filename = "${path.module}/manifests/logs_fluend_cloudwatch/values.yaml"
}

resource "null_resource" "deploy_fluentd" {
  count      = "${ var.enable_container_logs ? 1 : 0 }"
  depends_on = ["null_resource.install_tiller", "local_file.fluentd_config"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
helm install --namespace logs --name fluentd ${path.module}/manifests/logs_fluend_cloudwatch/ --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 15;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

data "template_file" "storage_class" {
  template = "${file("${path.module}/manifests_templates/monitoring/storageClass.tpl")}"

  vars = {
    availability_zone = "${local.pvc_az}"
  }
}

data "template_file" "grafana_pvc" {
  template = "${file("${path.module}/manifests_templates/monitoring/grafana-pvc.tpl")}"

  vars = {
    availability_zone = "${local.pvc_az}"
  }
}

data "template_file" "prometheus_operator_values" {
  template = "${file("${path.module}/manifests_templates/monitoring/prometheus-operator-values.tpl")}"

  vars = {
    external_dns_annotation = "${aws_route53_record.alb-route53-record.name}"
    ingress_domain          = "${var.root_domain}"
    availability_zone       = "${local.pvc_az}"
  }
}

data "template_file" "grafana_values" {
  template = "${file("${path.module}/manifests_templates/monitoring/grafana-values.tpl")}"

  vars = {
    external_dns_annotation = "${aws_route53_record.alb-route53-record.name}"
    ingress_domain          = "${var.root_domain}"
    availability_zone       = "${local.pvc_az}"
  }
}

resource "local_file" "storage_class" {
  content  = "${data.template_file.storage_class.rendered}"
  filename = "${path.module}/manifests/monitoring/storageClass.yaml"
}

resource "local_file" "grafana_pvc" {
  content  = "${data.template_file.grafana_pvc.rendered}"
  filename = "${path.module}/manifests/monitoring/grafana_pvc.yaml"
}

resource "local_file" "prometheus_operator_config" {
  content  = "${data.template_file.prometheus_operator_values.rendered}"
  filename = "${path.module}/manifests/monitoring/prometheus-operator-helm/values.yaml"
}

resource "local_file" "grafana_config" {
  content  = "${data.template_file.grafana_values.rendered}"
  filename = "${path.module}/manifests/monitoring/grafana-helm/values.yaml"
}

resource "null_resource" "deploy_monitoring" {
  count      = "${ var.enable_monitoring ? 1 : 0 }"
  depends_on = ["null_resource.install_tiller", "local_file.grafana_config", "local_file.prometheus_operator_config", "local_file.grafana_pvc", "local_file.storage_class"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f manifests/monitoring/storageClass.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
helm install --namespace monitoring --name prometheus-operator manifests/monitoring/prometheus-operator-helm/ --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
helm install --namespace kube-system --name termination-handler-exporter manifests/spot-termination-exporter/ --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
kubectl apply -f manifests/monitoring/grafana_pvc.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
helm install --namespace monitoring --name grafana manifests/monitoring/grafana-helm/ --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

data "template_file" "aws_alb_ingress_config" {
  template = "${file("${path.module}/manifests_templates/aws-alb-ingress/alb-ingress-controller.tpl")}"

  vars = {
    cluster_name = "${var.project}-${var.environment}"
    region       = "${data.aws_region.current.name}"
    vpc_id       = "${var.vpc_id}"
  }
}

resource "local_file" "aws_alb_ingress_config" {
  content  = "${data.template_file.aws_alb_ingress_config.rendered}"
  filename = "${path.module}/manifests/aws-alb-ingress/alb-ingress-controller.yaml"
}

resource "null_resource" "deploy_aws_alb_ingress" {
  count      = "${ var.deploy_aws_ingress ? 1 : 0 }"
  depends_on = ["null_resource.check_api", "local_file.aws_alb_ingress_config"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f manifests/aws-alb-ingress/rbac-role.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
kubectl apply -f manifests/aws-alb-ingress/alb-ingress-controller.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

resource "null_resource" "copy_manifests" {
  depends_on = ["null_resource.deploy_cluster_autoscaler", "local_file.grafana_config", "local_file.prometheus_operator_config", "local_file.grafana_pvc", "local_file.storage_class", "local_file.fluentd_config", "local_file.external_dns_manifest", "local_file.ingress_controller_service"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
cp -r ${path.module}/manifests ${path.root}/manifests_rendered
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

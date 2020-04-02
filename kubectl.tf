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


##### Template, save to S3 and deploy ingress_controller ##### 
data "template_file" "ingress_controller_service" {
  template = "${file("${path.module}/manifests_templates/nginx-ingress-service.tpl")}"

  vars = {
    node_port = "${var.target_group_port}"
  }
}

resource "aws_s3_bucket_object" "ingress_controller_service" {
  provider = "aws.tfstate"
  bucket = "${var.s3_bucket_name}"
  key    = "${var.project}/${var.environment}/manifests/3-nginx-ingress-service.yaml"
  content  = "${data.template_file.ingress_controller_service.rendered}"
}

resource "null_resource" "deploy_ingress_controller" {
  count      = "${ var.deploy_ingress_controller ? 1 : 0 }"

  depends_on = ["null_resource.check_api", "aws_s3_bucket_object.ingress_controller_service"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f manifests/nginx-ingress/1-namespace.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
kubectl apply -f manifests/nginx-ingress/2-nginx-ingress-rbac-deployment.yaml -f ${data.template_file.ingress_controller_service.rendered} -f manifests/nginx-ingress/4-default-http-backend.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}


##### Template, save to S3 and deploy external-dns ##### 
data "template_file" "external_dns_manifest" {
  template = "${file("${path.module}/manifests_templates/external-dns.tpl")}"

  vars = {
    root_domain = "${var.root_domain}"
    project     = "${var.project}"
    environment = "${var.environment}"
  }
}
resource "aws_s3_bucket_object" "external_dns_manifest" {
  provider = "aws.tfstate"
  bucket = "${var.s3_bucket_name}"
  key    = "${var.project}/${var.environment}/manifests/external_dns.yaml"
  content  = "${data.template_file.ingress_controller_service.rendered}"
}

resource "null_resource" "deploy_external_dns" {
  count      = "${ var.deploy_external_dns ? 1 : 0 }"
  depends_on = ["null_resource.check_api", "aws_s3_bucket_object.external_dns_manifest"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f ${data.template_file.external_dns_manifest.rendered} --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

##### Template, save to S3 and deploy cluster autoscaler ##### 
data "template_file" "cluster_autoscaler_config" {
  template = "${file("${path.module}/manifests_templates/cluster-autoscaler/kubernetes-autoscaler.tpl")}"

  vars = {
    cluster_name = "${var.project}-${var.environment}"
    region       = "${data.aws_region.current.name}"
  }
}

resource "aws_s3_bucket_object" "cluster_autoscaler_config" {
  provider = "aws.tfstate"
  bucket = "${var.s3_bucket_name}"
  key    = "${var.project}/${var.environment}/manifests/cluster-autoscaler/kubernetes-autoscaler.yaml"
  content  = "${data.template_file.cluster_autoscaler_config.rendered}"
}

data "template_file" "cluster_autoscaler_priority_configmap" {
  template = "${file("${path.module}/manifests_templates/cluster-autoscaler/autoscaler-priority.tpl")}"

  vars = {
    project     = "${var.project}"
    environment = "${var.environment}"
  }
}

resource "aws_s3_bucket_object" "cluster_autoscaler_priority_configmap" {
  provider = "aws.tfstate"
  bucket = "${var.s3_bucket_name}"
  key    = "${var.project}/${var.environment}/manifests/cluster-autoscaler/autoscaler-priority.yaml"
  content  = "${data.template_file.cluster_autoscaler_priority_configmap.rendered}"
}

resource "null_resource" "deploy_cluster_autoscaler" {
  depends_on = ["aws_s3_bucket_object.cluster_autoscaler_config", "null_resource.priority_class", "aws_s3_bucket_object.cluster_autoscaler_priority_configmap"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f ${data.template_file.cluster_autoscaler_priority_configmap.rendered} --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
kubectl apply -f ${data.template_file.cluster_autoscaler_config.rendered} --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
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

##### Template, save to S3 and deploy logging, monitoring, etc... ##### 
data "template_file" "fluentd_config" {
  template = "${file("${path.module}/manifests_templates/fluentd_values.tpl")}"

  vars = {
    region          = "${data.aws_region.current.name}"
    project         = "${var.project}"
    environment     = "${var.environment}"
    iam_worker_role = "${module.eks.worker_iam_role_name}"
  }
}

resource "aws_s3_bucket_object" "fluentd_config" {
  provider = "aws.tfstate"
  bucket = "${var.s3_bucket_name}"
  key    = "${var.project}/${var.environment}/manifests/logs_fluend_cloudwatch/values.yaml"
  content  = "${data.template_file.fluentd_config.rendered}"
}

resource "null_resource" "deploy_fluentd" {
  count      = "${ var.enable_container_logs ? 1 : 0 }"
  depends_on = ["null_resource.install_tiller", "aws_s3_bucket_object.fluentd_config"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
helm install --namespace logs --name fluentd ${path.module}/manifests/logs_fluend_cloudwatch/ --values ${data.template_file.fluentd_config.rendered} --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
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

resource "aws_s3_bucket_object" "storage_class" {
  provider = "aws.tfstate"
  bucket = "${var.s3_bucket_name}"
  key    = "${var.project}/${var.environment}/manifests/monitoring/storageClass.yaml"
  content  = "${data.template_file.storage_class.rendered}"
}

resource "aws_s3_bucket_object" "grafana_pvc" {
  provider = "aws.tfstate"
  bucket = "${var.s3_bucket_name}"
  key    = "${var.project}/${var.environment}/manifests/monitoring/grafana_pvc.yaml"
  content  = "${data.template_file.grafana_pvc.rendered}"
}

resource "aws_s3_bucket_object" "prometheus_operator_config" {
  provider = "aws.tfstate"
  bucket = "${var.s3_bucket_name}"
  key    = "${var.project}/${var.environment}/manifests/monitoring/prometheus-operator-helm/values.yaml"
  content  = "${data.template_file.prometheus_operator_values.rendered}"
}

resource "aws_s3_bucket_object" "grafana_config" {
  provider = "aws.tfstate"
  bucket = "${var.s3_bucket_name}"
  key    = "${var.project}/${var.environment}/manifests/monitoring/grafana-helm/values.yaml"
  content  = "${data.template_file.grafana_values.rendered}"
}

resource "null_resource" "deploy_monitoring" {
  count      = "${ var.enable_monitoring ? 1 : 0 }"
  depends_on = ["null_resource.install_tiller", "aws_s3_bucket_object.grafana_config", "aws_s3_bucket_object.prometheus_operator_config", "aws_s3_bucket_object.grafana_pvc", "aws_s3_bucket_object.storage_class"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f ${data.template_file.storage_class.rendered} --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
helm install --namespace monitoring --name prometheus-operator manifests/monitoring/prometheus-operator-helm/ --values ${data.template_file.prometheus_operator_values.rendered} --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
helm install --namespace kube-system --name termination-handler-exporter manifests/spot-termination-exporter/ --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
kubectl apply -f ${data.template_file.grafana_pvc.rendered} --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
helm install --namespace monitoring --name grafana manifests/monitoring/grafana-helm/ --values ${data.template_file.grafana_values.rendered} --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

resource "null_resource" "copy_manifests" {
  depends_on = ["null_resource.deploy_cluster_autoscaler", "aws_s3_bucket_object.grafana_config", "aws_s3_bucket_object.prometheus_operator_config", "aws_s3_bucket_object.grafana_pvc", "aws_s3_bucket_object.storage_class", "aws_s3_bucket_object.fluentd_config", "aws_s3_bucket_object.external_dns_manifest", "aws_s3_bucket_object.ingress_controller_service"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
cp -r ${path.module}/manifests ${path.root}/manifests_rendered
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

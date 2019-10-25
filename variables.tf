variable "project" {
  description = "Project name is used to identify resources"
  type        = "string"
}

variable "environment" {
  description = "Environment name is used to identify resources"
  type        = "string"
}

variable "root_domain" {
  description = "Root domain in which custom DNS record for ALB would be created"
}

variable "alternative_domains_count" {
  description = "Alternative domains count for ACM certificate"
  default     = "0"
}

variable "alternative_domains" {
  description = "Alternative domains for ACM certificate dns records with ',' as delimiter"
  default     = []
}

variable "alb_route53_record" {
  description = "Alias Route53 DNS record name for ALB"
}

variable "alb_ingress_rules" {
  description = "List of maps that contains ingress rules for ALB security group"
  type        = "list"
  default     = [
    {
      from_port = 80,
      to_port = 80,
      protocol = "tcp",
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 443,
      to_port = 443,
      protocol = "tcp",
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

variable "cidr_whitelist" {
  description = "List of maps that contains IP CIDR with protocol type. Example provided in module examples"
  default     = []
}

variable "enable_waf" {
  description = "Set true to enable Web Application Firewall for whitelisting"
  default = false
}

variable "create_acm_certificate" {
  description = "Set true for ACM certificate for ALB creation"
  default = true
}

variable "target_group_port" {
  description = "ALB targer group port. This value will be used as NodePort for Nginx Ingress controller service."
  type        = "string"
  default     = "30080"
}

variable "local_exec_interpreter" {
  description = "Command to run for local-exec resources. Must be a shell-style interpreter. If you are on Windows Git Bash is a good choice."
  type        = "list"
  default     = ["/bin/sh", "-c"]
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  default     = "1.14"
}

variable "cluster_enabled_log_types" {
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = "list"
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format."
  type        = "list"
  default     = []
}

variable "map_roles_count" {
  description = "The count of roles in the map_roles list."
  type        = "string"
  default     = "0"
}

variable "vpc_id" {
  description = "VPC ID for cluster provisioning"
  type        = "string"
}

variable "private_subnets" {
  description = "List of private subnets for cluster worker nodes provisioning"
  type        = "list"
}

variable "public_subnets" {
  description = "List of public subnets for ALB provisioning"
  type        = "list"
}

#########################WORKER_NODES#########################
variable "volume_size" {
  description = "Volume size(GB) for worker node in cluster"
  type        = "string"
  default     = "50"
}

variable "worker_nodes_ssh_key" {
  description = "If Public ssh key provided, will be used for ssh access to worker nodes. Otherwise instances will be created without ssh key."
  type        = "string"
  default     = ""
}

variable "spot_configuration" {
  description = "List of maps that contains configurations for ASGs with spot workers instances what will be used in EKS-cluster"
  type        = "list"
  default     = [
    {
      instance_type = "m4.large",
      spot_price    = "0.05",
      asg_max_size  = "4",
      asg_min_size  = "1",
      asg_desired_capacity = "1",
      additional_kubelet_args = ""
    },
    {
      instance_type = "m4.xlarge",
      spot_price    = "0.08",
      asg_max_size  = "4",
      asg_min_size  = "0",
      asg_desired_capacity = "0",
      additional_kubelet_args = ""
    }
  ]
}

variable "on_demand_configuration" {
  description = "List of maps that contains configurations for ASGs with on-demand workers instances what will be used in EKS-cluster"
  type        = "list"
  default     = [
    {
      instance_type = "m4.xlarge",
      asg_max_size  = "6",
      asg_min_size  = "0",
      asg_desired_capacity = "0",
      additional_kubelet_args = ""
    }
  ]
}

variable "service_on_demand_configuration" {
  description = "List of maps that contains configurations for ASGs with on-demand workers instances what will be used in EKS-cluster"
  type        = "list"
  default     = [
    {
      instance_type = "t3.small",
      asg_max_size  = "1",
      asg_min_size  = "1",
      asg_desired_capacity = "1",
      additional_kubelet_args = ""
    }
  ]
}

#########################DEPLOYMENTS FOR EKS CLUSTER#########################

variable "deploy_ingress_controller" {
  description = "Set true for nginx ingress controller installation (https://github.com/kubernetes/ingress-nginx#nginx-ingress-controller)"
  type        = "string"
  default     = "true"
}

variable "deploy_external_dns" {
  description = "Set true for External DNS installation (https://github.com/kubernetes-incubator/external-dns#externaldns)"
  type        = "string"
  default     = "false"
}

variable "enable_container_logs" {
  description = "Set true to install fluentd and store container logs in AWS CloudWatch log group (https://github.com/helm/charts/tree/master/incubator/fluentd-cloudwatch#fluentd-cloudwatch)"
  type        = "string"
  default     = "false"
}

variable "container_logs_retention_days" {
  description = "Set retention period for AWS CloudWatch log group with container logs"
  type        = "string"
  default     = "5"
}

variable "enable_monitoring" {
  description = "Set true for prometheus-operator (https://github.com/helm/charts/tree/master/stable/prometheus-operator#prometheus-operator) and grafana (https://github.com/helm/charts/tree/master/stable/grafana#grafana-helm-chart) deployment. Also storageClass will be created."
  type        = "string"
  default     = "false"
}

variable "monitoring_availability_zone" {
  description = "Availability zone in which will be deployed grafana and prometheus-operator, as this deployments required persistent volumes for data storing. If variable not set - availability zone of first subnet in private_subnets array will be used."
  type        = "string"
  default     = ""
}

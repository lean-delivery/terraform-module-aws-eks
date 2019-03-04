# Terraform EKS module

## Description

Creating EKS Cluster via Terraform on AWS, followed by setting and deploying of applications on kubernetes-cluster

### Includes modules
 * terraform-aws-modules/eks/aws
 * AS_policys

The module allows you to deploy an EKS cluster in AWS. Automatically will be created:

 * IAM-Policys
 * Iam-Roles
 * AutoScaling-group
 * Security-Groups
 * EKS-cluster
 * Instances

The cluster automatically uses spot-instances if you set spot_price.
Module uses [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) from [Terraform AWS modules](https://github.com/terraform-aws-modules) (No-Verified module), and adds aws_autoscaling_policy for scaling ASG.



## Requirements:
### For creating cluster (module eks-orchestration)
* vpc_id
* subnets_id

### For creating metrics (autoscaling policy and cloudwatch metric alarm. Module AS_policys)
* autoscaling group name (Can take from eks-orchestration)
* lists of scaling policys (4 types: SimpleScaling_policys, SimpleAlarmScaling_policys, StepScaling_policys, TargetTracking_policys)

### Also you need to have
* awscli
* kubectl (For further management of the cluster)

## Usage

```hcl
module "Cluster" {
  source                 = "eks-orchestration/"
  vpc_id                 = "vpc-XXXXXXXX"
  subnets_id             = ["subnet-XXXXXXXX","subnet-XXXXXXXX","subnet-XXXXXXXX"]
  instance_type          = "m4.large"
  asg_max_size           = "10"
  spot_price             = "0.05"
  ami_id                 = "ami-0c2e8d28b1f854c68"
}

module "AS_Polisys" {
  source = "AS_policys/"
  autoscaling_group_name = "${element(module.Cluster.workers_asg_names, 0)}"

  SimpleScaling_policys = [
    {
      estimated_instance_warmup = ""
      adjustment_type           = "ChangeInCapacity"
      policy_type               = "SimpleScaling"
      cooldown                  = "300"
      scaling_adjustment        = "0"
    },
  ]
}
```

## Table AMI
Use specified AMI for parameter ami_id

### Kubernetes version 1.11
| Region | Region ID | Amazon EKS-optimized AMI | with GPU support |
|--------|-----------|--------------------------|------------------|
| US West (Oregon) | us-west-2 | ami-0a2abab4107669c1b | ami-0c9e5e2d8caa9fb5e |
| US East (N. Virginia) | us-east-1 | ami-0c24db5df6badc35a | ami-0ff0241c02b279f50 |
| US East (Ohio) | us-east-2 | ami-0c2e8d28b1f854c68 | ami-006a12f54eaafc2b1 |
| EU (Frankfurt) | eu-central-1 | ami-010caa98bae9a09e2 | ami-0d6f0554fd4743a9d |
| EU (Stockholm) | eu-north-1 | ami-06ee67302ab7cf838 | ami-0b159b75 |
| EU (Ireland) | eu-west-1 | ami-01e08d22b9439c15a | ami-097978e7acde1fd7c |
| Asia Pacific (Tokyo) | ap-northeast-1 | ami-0f0e8066383e7a2cb | ami-036b3969c5eb8d3cf |
| Asia Pacific (Seoul) | ap-northeast-2 | ami-0b7baa90de70f683f | ami-0b7f163f7194396f7 |
| Asia Pacific (Singapore) | ap-southeast-1 | ami-019966ed970c18502 | ami-093f742654a955ee6 |
| Asia Pacific (Sydney) | ap-southeast-2 | ami-06ade0abbd8eca425 | ami-05e09575123ff498b |

### Kubernetes version 1.10
| Region | Region ID | Amazon EKS-optimized AMI | with GPU support |
|--------|-----------|--------------------------|------------------|
| US West (Oregon) | us-west-2 | ami-09e1df3bad220af0b | ami-0ebf0561e61a2be02 |
| US East (N. Virginia) | us-east-1 | ami-04358410d28eaab63 | ami-0131c0ca222183def |
| US East (Ohio) | us-east-2 | ami-0b779e8ab57655b4b | ami-0abfb3be33c196cbf |
| EU (Frankfurt) | eu-central-1 | ami-08eb700778f03ea94 | ami-000622b1016d2a5bf |
| EU (Stockholm) | eu-north-1 | ami-068b8a1efffd30eda | ami-cc149ab2 |
| EU (Ireland) | eu-west-1 | ami-0de10c614955da932 | ami-0dafd3a1dc43781f7 |
| Asia Pacific (Tokyo) | ap-northeast-1 | ami-06398bdd37d76571d | ami-0afc9d14b2fe11ad9 |
| Asia Pacific (Seoul) | ap-northeast-2 | ami-08a87e0a7c32fa649 | ami-0d75b9ab57bfc8c9a |
| Asia Pacific (Singapore) | ap-southeast-1 | ami-0ac3510e44b5bf8ef | ami-0ecce0670cb66d17b |
| Asia Pacific (Sydney) | ap-southeast-2 | ami-0d2c929ace88cfebe | ami-03b048bd9d3861ce9 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| vpc_id | VPC where the cluster and workers will be deployed | string | n/a | yes |
| subnets_id | A list of subnets to place the EKS cluster and workers within | list | n/a | yes |
| project | Project name is used to identify resources | string | test | no |
| environment | Environment name is used to identify resources | string | env | no |
| ami_id | AMI ID for the eks workers. Look AMI-s table | string | n/a | yes |
| asg_desired_capacity | Desired worker capacity in the autoscaling group. | string | 1 | no |
| asg_min_size | Minimum worker capacity in the autoscaling group. | string | 1 | no |
| placement_tenancy | The tenancy of the instance. Valid values are default or dedicated. | string | "" | no |
| root_volume_size | root volume size of workers instances. | string | 100 | no |
| root_volume_type | root volume type of workers instances can be standard gp2 or io1 | string | gp2 | no |
| root_iops | The amount of provisioned IOPS. This must be set with a volume_type of io1. | string | 0 | no |
| key_name | The key name that should be used for the instances in the autoscaling group | string | "" | no |
| pre_userdata | userdata to pre-append to the default userdata. | string | "" | no |
| additional_userdata | userdata to append to the default userdata. | string | "" | no |
| ebs_optimized | sets whether to use ebs optimization on supported types. | boolean | true | no |
| enable_monitoring | Enables/disables detailed monitoring. | boolean | true | no |
| public_ip | Associate a public ip address with a worker | boolean | false | no |
| kubelet_extra_args | This string is passed directly to kubelet if set. Useful for adding labels or taints. | string | "" | no |
| autoscaling_enabled | Sets whether policy and matching tags will be added to allow autoscaling. | boolean | true | no |
| additional_security_group_ids | A comma delimited list of additional security group ids to include in worker launch config | string | "" | no |
| protect_from_scale_in | Prevent AWS from scaling in, so that cluster-autoscaler is solely responsible. | boolean | false | no |
| suspended_processes | A comma delimited string of processes to to suspend. i.e. AZRebalance HealthCheck ReplaceUnhealthy | string | "" | no |
| target_group_arns | A comma delimited list of ALB target group ARNs to be associated to the ASG | string | "" | no |
| instance_type | Size of the workers instances what will be used in EKS-cluster | string | m4.large | no |
| asg_max_size | Maximum worker capacity in in cluster | string | 5 | no |
| spot_price | Cost of spot instance. Value 1 equals one dollar. 0.01 equals one cent. Set this variable if you want run cluster on spot instances | string | 0.1 | no |
| SimpleScaling_policys | A list of AS-policys. Trigger for scaling ASG. Only policy_type SimpleScaling | list | [] | no |
| StepScaling_policys | A list of AS-policys. Trigger for scaling ASG. Only policy_type StepScaling | list | [] | no |
| SimpleAlarmScaling_policys | A list of AS-policys. Trigger for scaling ASG. Only policy_type SimpleScaling | list | [] | no |
| TargetTracking_policys | A list of AS-policys. Trigger for scaling ASG. Only policy_type TargetTrackingScaling | list | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_certificate_authority_data | Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster |
| cluster_endpoint | The endpoint for your EKS Kubernetes API |
| cluster_id | The name/id of the EKS cluster |
| cluster_security_group_id | Security group ID attached to the EKS cluster |
| cluster_version | The Kubernetes server version for the EKS cluster |
| config_map_aws_auth | A kubernetes configuration to authenticate to this EKS cluster |
| kubeconfig | kubectl config file contents for this EKS cluster |
| worker_iam_role_arn | default IAM role ARN for EKS worker groups |
| worker_iam_role_name | default IAM role name for EKS worker groups |
| worker_security_group_id | Security group ID attached to the EKS workers |
| workers_asg_arns | IDs of the autoscaling groups containing workers |
| workers_asg_names | Names of the autoscaling groups containing workers |
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

## Terraform versions
Terraform v0.11.11

## Contributing


## License
Apache

## Authors
Lean Delivery Team team@lean-delivery.com

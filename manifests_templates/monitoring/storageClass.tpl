apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: 'gp2-${availability_zone}'
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
  fsType: ext4
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowedTopologies:
  - matchLabelExpressions:
    - key: failure-domain.beta.kubernetes.io/zone
      values:
      - '${availability_zone}'

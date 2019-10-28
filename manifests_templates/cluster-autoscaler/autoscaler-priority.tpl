apiVersion: v1
kind: ConfigMap
metadata:
  namespace: kube-system
  name: cluster-autoscaler-priority-expander
data:
  priorities: |-
    100:
      - ^${project}-${environment}-spot.*
    50:
      - ^${project}-${environment}-on-demand.*

#!/bin/bash -xe

# Allow user supplied pre userdata code


# Bootstrap and join the cluster
/etc/eks/bootstrap.sh --b64-cluster-ca '${certificate_data}' --apiserver-endpoint '${api_endpoint}' --kubelet-extra-args '--node-labels=service_node=true ${additional_kubelet_args}' '${project}-${environment}'

# Allow user supplied userdata code

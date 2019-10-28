image:
  repository: fluent/fluentd-kubernetes-daemonset
  tag: v1.3.3-debian-cloudwatch-1.0
## Specify an imagePullPolicy (Required)
## It's recommended to change this to 'Always' if the image tag is 'latest'
## ref: http://kubernetes.io/docs/user-guide/images/#updating-images
  pullPolicy: IfNotPresent

## Configure resource requests and limits
## ref: http://kubernetes.io/docs/user-guide/compute-resources/
##
resources:
  limits:
   cpu: 100m
   memory: 200Mi
  requests:
   cpu: 100m
   memory: 200Mi
# We usually recommend not to specify default resources and to leave this as a conscious
# choice for the user. This also increases chances charts run on environments with little
# resources, such as Minikube. If you do want to specify resources, uncomment the following
# lines, adjust them as necessary, and remove the curly braces after 'resources:'.
#  limits:
#    cpu: 100m
#    memory: 200Mi
#  requests:
#    cpu: 100m
#    memory: 200Mi

# hostNetwork: false

## Node labels for pod assignment
## Ref: https://kubernetes.io/docs/user-guide/node-selection/
##
nodeSelector: {}
  # kubernetes.io/role: node
# Ref: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#affinity-v1-core
# Expects input structure as per specification for example:
#   affinity:
#     nodeAffinity:
#      requiredDuringSchedulingIgnoredDuringExecution:
#        nodeSelectorTerms:
#        - matchExpressions:
#          - key: foo.bar.com/role
#            operator: In
#            values:
#            - master
affinity: {}
## Add tolerations if specified
tolerations: []
#   - key: node-role.kubernetes.io/master
#     operator: Exists
#     effect: NoSchedule

podSecurityContext: {}

podAnnotations: {}

# Pod priority
# Sets PriorityClassName if defined.
#
# priorityClassName: "my-priority-class"

awsRegion: '${region}'
awsRole: '${iam_worker_role}'
awsAccessKeyId:
awsSecretAccessKey:
logGroupName:  '${project}-${environment}-container-logs'

rbac:
  ## If true, create and use RBAC resources
  create: true

  ## Ignored if rbac.create is true
  serviceAccountName: default
# Add extra environment variables if specified (must be specified as a single line object and be quoted)
extraVars: []
# - "{ name: NODE_NAME, valueFrom: { fieldRef: { fieldPath: spec.nodeName } } }"

busybox:
  repository: busybox
  tag: 1.31.0

updateStrategy:
  type: OnDelete

data:
  fluent.conf: |

    <match fluent.**>
      @type null
    </match>

    <source>
      @type tail
      enable_stat_watcher false
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%NZ
      tag kubernetes.*
      format json
      read_from_head true
    </source>

    <source>
      @type tail
      enable_stat_watcher false
      format /^(?<time>[^ ]* [^ ,]*)[^\[]*\[[^\]]*\]\[(?<severity>[^ \]]*) *\] (?<message>.*)$/
      time_format %Y-%m-%d %H:%M:%S
      path /var/log/salt/minion
      pos_file /var/log/fluentd-salt.pos
      tag salt
    </source>

    <source>
      @type tail
      enable_stat_watcher false
      format syslog
      path /var/log/startupscript.log
      pos_file /var/log/fluentd-startupscript.log.pos
      tag startupscript
    </source>

    <source>
      @type tail
      enable_stat_watcher false
      format /^time="(?<time>[^)]*)" level=(?<severity>[^ ]*) msg="(?<message>[^"]*)"( err="(?<error>[^"]*)")?( statusCode=($<status_code>\d+))?/
      path /var/log/docker.log
      pos_file /var/log/fluentd-docker.log.pos
      tag docker
    </source>

    <source>
      @type tail
      enable_stat_watcher false
      format none
      path /var/log/etcd.log
      pos_file /var/log/fluentd-etcd.log.pos
      tag etcd
    </source>

    <source>
      @type tail
      enable_stat_watcher false
      format kubernetes
      multiline_flush_interval 5s
      path /var/log/kubelet.log
      pos_file /var/log/fluentd-kubelet.log.pos
      tag kubelet
    </source>

    <source>
      @type tail
      enable_stat_watcher false
      format kubernetes
      multiline_flush_interval 5s
      path /var/log/kube-proxy.log
      pos_file /var/log/fluentd-kube-proxy.log.pos
      tag kube-proxy
    </source>

    <source>
      @type tail
      enable_stat_watcher false
      format kubernetes
      multiline_flush_interval 5s
      path /var/log/kube-apiserver.log
      pos_file /var/log/fluentd-kube-apiserver.log.pos
      tag kube-apiserver
    </source>

    <source>
      @type tail
      enable_stat_watcher false
      format kubernetes
      multiline_flush_interval 5s
      path /var/log/kube-controller-manager.log
      pos_file /var/log/fluentd-kube-controller-manager.log.pos
      tag kube-controller-manager
    </source>

    <source>
      @type tail
      enable_stat_watcher false
      format kubernetes
      multiline_flush_interval 5s
      path /var/log/kube-scheduler.log
      pos_file /var/log/fluentd-kube-scheduler.log.pos
      tag kube-scheduler
    </source>

    <source>
      @type tail
      enable_stat_watcher false
      format kubernetes
      multiline_flush_interval 5s
      path /var/log/rescheduler.log
      pos_file /var/log/fluentd-rescheduler.log.pos
      tag rescheduler
    </source>

    <source>
      @type tail
      enable_stat_watcher false
      format kubernetes
      multiline_flush_interval 5s
      path /var/log/glbc.log
      pos_file /var/log/fluentd-glbc.log.pos
      tag glbc
    </source>

    <source>
      @type tail
      enable_stat_watcher false
      format kubernetes
      multiline_flush_interval 5s
      path /var/log/cluster-autoscaler.log
      pos_file /var/log/fluentd-cluster-autoscaler.log.pos
      tag cluster-autoscaler
    </source>

    <filter kubernetes.**>
      @type kubernetes_metadata
    </filter>

    <filter kubernetes.var.log.containers.nginx-ingress-controller-**>
      @type parser
      format /^(?<host>[^ ]*) (?<domain>[^ ]*) \[(?<x_forwarded_for>[^\]]*)\] (?<server_port>[^ ]*) (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+[^\"])(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")? (?<request_length>[^ ]*) (?<request_time>[^ ]*) (?:\[(?<proxy_upstream_name>[^\]]*)\] )?(?<upstream_addr>[^ ]*) (?<upstream_response_length>[^ ]*) (?<upstream_response_time>[^ ]*) (?<upstream_status>[^ ]*) (?<request_id>[^ ]*)\n$/
      time_format %d/%b/%Y:%H:%M:%S %z
      key_name log
      remove_key_name_field true
      reserve_data yes
    </filter>

    <filter kubernetes.**>
      @type record_transformer
      enable_ruby true
      <record>
        host_ec2 $${record.fetch("kubernetes", Hash.new).fetch("host")}
        namespace $${record.fetch("kubernetes", Hash.new).fetch("namespace_name")}
        pod_name $${record.fetch("kubernetes", Hash.new).fetch("pod_name", "unknown_pod")}
        container_name $${record.fetch("kubernetes", Hash.new).fetch("container_name", "unknown_container")}
        container_image $${record.fetch("kubernetes", Hash.new).fetch("container_image", "unknown_pod")}
        custom_stream_name $${record.fetch("kubernetes", Hash.new).fetch("namespace_name")}/$${record.fetch("kubernetes", Hash.new).fetch("pod_name", "unknown_pod")}/$${record.fetch("kubernetes", Hash.new).fetch("container_name", "unknown_container")}
      </record>
    </filter>

    <filter kubernetes.**>
      @type record_transformer
      remove_keys kubernetes,docker
    </filter>

    <match kubernetes.var.log.containers.fluent**>
      @type null
    </match>

    <match **>
      @type cloudwatch_logs
      log_group_name "#{ENV['LOG_GROUP_NAME']}"
      auto_create_stream true
      log_stream_name_key "custom_stream_name"
    </match>

serviceMonitor:
  ## Scrape interval. If not set, the Prometheus default scrape interval is used.
  ##
  interval: ""
  selfMonitor: true
  prometheusOperatorRelease: prometheus-operator

  ## 	metric relabel configs to apply to samples before ingestion.
  ##
  metricRelabelings: []
  # - action: keep
  #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
  #   sourceLabels: [__name__]

  # 	relabel configs to apply to samples before ingestion.
  ##
  relabelings: []
  # - sourceLabels: [__meta_kubernetes_pod_node_name]
  #   separator: ;
  #   regex: ^(.*)$
  #   target_label: nodename
  #   replacement: $1
  #   action: replace

rbac:
  create: true
  pspEnabled: true
  pspUseAppArmor: true
  namespaced: false
serviceAccount:
  create: true
  name:
  nameTest:

replicas: 1

## See `kubectl explain deployment.spec.strategy` for more
## ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy
deploymentStrategy:
  type: RollingUpdate
  rollingUpdate: null

readinessProbe:
  httpGet:
    path: /api/health
    port: 3000

livenessProbe:
  httpGet:
    path: /api/health
    port: 3000
  initialDelaySeconds: 60
  timeoutSeconds: 30
  failureThreshold: 10

## Use an alternate scheduler, e.g. "stork".
## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
##
# schedulerName: "default-scheduler"

image:
  repository: grafana/grafana
  tag: 6.2.5
  pullPolicy: IfNotPresent

  ## Optionally specify an array of imagePullSecrets.
  ## Secrets must be manually created in the namespace.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
  ##
  # pullSecrets:
  #   - myRegistrKeySecretName

testFramework:
  image: "dduportal/bats"
  tag: "0.4.0"

securityContext:
  runAsUser: 472
  fsGroup: 472


extraConfigmapMounts: []
  # - name: certs-configmap
  #   mountPath: /etc/grafana/ssl/
  #   configMap: certs-configmap
  #   readOnly: true


extraEmptyDirMounts: []
  # - name: provisioning-notifiers
  #   mountPath: /etc/grafana/provisioning/notifiers


## Assign a PriorityClassName to pods if set
# priorityClassName:

downloadDashboardsImage:
  repository: appropriate/curl
  tag: latest
  pullPolicy: IfNotPresent

## Pod Annotations
# podAnnotations: {}

## Deployment annotations
# annotations: {}

## Expose the grafana service to be accessed from outside the cluster (LoadBalancer service).
## or access it from within the cluster (ClusterIP service). Set the service type and the port to serve it.
## ref: http://kubernetes.io/docs/user-guide/services/
##
service:
  type: ClusterIP
  port: 80
  targetPort: 3000
    # targetPort: 4181 To be used with a proxy extraContainer
  annotations: {}
  labels: {}

ingress:
  enabled: true
  annotations:
    external-dns.alpha.kubernetes.io/target: '${external_dns_annotation}'
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  labels: {}
  path: /
  hosts:
    - grafana.${ingress_domain}
  tls: []
  #  - secretName: chart-example-tls
  #    hosts:
  #      - chart-example.local

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

## Node labels for pod assignment
## ref: https://kubernetes.io/docs/user-guide/node-selection/
#
nodeSelector:
  failure-domain.beta.kubernetes.io/zone: ${availability_zone}
## Tolerations for pod assignment
## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
##
tolerations: []

## Affinity for pod assignment
## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
##
affinity: {}

extraInitContainers: []

## Enable an Specify container in extraContainers. This is meant to allow adding an authentication proxy to a grafana pod
extraContainers: |
# - name: proxy
#   image: quay.io/gambol99/keycloak-proxy:latest
#   args:
#   - -provider=github
#   - -client-id=
#   - -client-secret=
#   - -github-org=<ORG_NAME>
#   - -email-domain=*
#   - -cookie-secret=
#   - -http-address=http://0.0.0.0:4181
#   - -upstream-url=http://127.0.0.1:3000
#   ports:
#     - name: proxy-web
#       containerPort: 4181

## Enable persistence using Persistent Volume Claims
## ref: http://kubernetes.io/docs/user-guide/persistent-volumes/
##
persistence:
  enabled: true
  # storageClassName: gp2
  # accessModes:
  #   - ReadWriteOnce
  # size: 1Gi
  # # annotations: {}
  # finalizers:
  #   - kubernetes.io/pvc-protection
  # subPath: ""
  existingClaim: grafana

initChownData:
  ## If false, data ownership will not be reset at startup
  ## This allows the prometheus-server to be run with an arbitrary user
  ##
  enabled: true

  ## initChownData container image
  ##
  image:
    repository: busybox
    tag: "1.30"
    pullPolicy: IfNotPresent

  ## initChownData resource requests and limits
  ## Ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ##
  resources: {}
  #  limits:
  #    cpu: 100m
  #    memory: 128Mi
  #  requests:
  #    cpu: 100m
  #    memory: 128Mi


# Administrator credentials when not using an existing secret (see below)
adminUser: admin
adminPassword: mk<^W3Ja

# Use an existing secret for the admin user.
admin:
  existingSecret: ""
  userKey: admin-user
  passwordKey: admin-password

## Define command to be executed at startup by grafana container
## Needed if using `vault-env` to manage secrets (ref: https://banzaicloud.com/blog/inject-secrets-into-pods-vault/)
## Default is "run.sh" as defined in grafana's Dockerfile
# command:
# - "sh"
# - "/run.sh"

## Use an alternate scheduler, e.g. "stork".
## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
##
# schedulerName:

## Extra environment variables that will be pass onto deployment pods
env: {}

## The name of a secret in the same kubernetes namespace which contain values to be added to the environment
## This can be useful for auth tokens, etc
envFromSecret: ""

## Additional grafana server secret mounts
# Defines additional mounts with secrets. Secrets must be manually created in the namespace.
extraSecretMounts: []
  # - name: secret-files
  #   mountPath: /etc/secrets
  #   secretName: grafana-secret-files
  #   readOnly: true

## Additional grafana server volume mounts
# Defines additional volume mounts.
extraVolumeMounts: []
  # - name: extra-volume
  #   mountPath: /mnt/volume
  #   readOnly: true
  #   existingClaim: volume-claim

## Pass the plugins you want installed as a list.
##
plugins: []
  # - digrich-bubblechart-panel
  # - grafana-clock-panel

## Configure grafana datasources
## ref: http://docs.grafana.org/administration/provisioning/#datasources
##
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-operator-prometheus:9090/
      access: proxy
      isDefault: true

## Configure notifiers
## ref: http://docs.grafana.org/administration/provisioning/#alert-notification-channels
##
notifiers: {}
#  notifiers.yaml:
#    notifiers:
#    - name: email-notifier
#      type: email
#      uid: email1
#      # either:
#      org_id: 1
#      # or
#      org_name: Main Org.
#      is_default: true
#      settings:
#        addresses: an_email_address@example.com
#    delete_notifiers:

## Configure grafana dashboard providers
## ref: http://docs.grafana.org/administration/provisioning/#dashboards
##
## `path` must be /var/lib/grafana/dashboards/<provider_name>
##
dashboardProviders: {}
  # provider.yaml: |-
  #   apiVersion: 1
  #   providers:
  #   - name: 'default'
  #     orgId: 1
  #     folder: ''
  #     type: file
  #     disableDeletion: false
  #     options:
  #       path: /tmp/dashboards

defaultDashboardsEnabled: true

## Configure grafana dashboard to import
## NOTE: To use dashboards you must also enable/configure dashboardProviders
## ref: https://grafana.com/dashboards
##
## dashboards per provider, use provider name as key.
##
dashboards: {}
  # default:
  #   k8s-cluster-rsrc-use:
  #     file: dashboards/k8s-cluster-rsrc-use.json
  # default:
  #   custom-dashboard:
  #     file: dashboards/custom-dashboard.json
  #   prometheus-stats:
  #     gnetId: 2
  #     revision: 2
  #     datasource: Prometheus
  #   local-dashboard:
  #     url: https://example.com/repository/test.json
  #   local-dashboard-base64:
  #     url: https://example.com/repository/test-b64.json
  #     b64content: true

## Reference to external ConfigMap per provider. Use provider name as key and ConfiMap name as value.
## A provider dashboards must be defined either by external ConfigMaps or in values.yaml, not in both.
## ConfigMap data example:
##
## data:
##   example-dashboard.json: |
##     RAW_JSON
##
dashboardsConfigMaps: {}
#  default: ""

## Grafana's primary configuration
## NOTE: values in map will be converted to ini format
## ref: http://docs.grafana.org/installation/configuration/
##
grafana.ini:
  paths:
    data: /var/lib/grafana/data
    logs: /var/log/grafana
    plugins: /var/lib/grafana/plugins
    provisioning: /etc/grafana/provisioning
  analytics:
    check_for_updates: true
  log:
    mode: console
  grafana_net:
    url: https://grafana.net
## LDAP Authentication can be enabled with the following values on grafana.ini
## NOTE: Grafana will fail to start if the value for ldap.toml is invalid
  # auth.ldap:
  #   enabled: true
  #   allow_sign_up: true
  #   config_file: /etc/grafana/ldap.toml

## Grafana's LDAP configuration
## Templated by the template in _helpers.tpl
## NOTE: To enable the grafana.ini must be configured with auth.ldap.enabled
## ref: http://docs.grafana.org/installation/configuration/#auth-ldap
## ref: http://docs.grafana.org/installation/ldap/#configuration
ldap:
  # `existingSecret` is a reference to an existing secret containing the ldap configuration
  # for Grafana in a key `ldap-toml`.
  existingSecret: ""
  # `config` is the content of `ldap.toml` that will be stored in the created secret
  config: ""
  # config: |-
  #   verbose_logging = true

  #   [[servers]]
  #   host = "my-ldap-server"
  #   port = 636
  #   use_ssl = true
  #   start_tls = false
  #   ssl_skip_verify = false
  #   bind_dn = "uid=%s,ou=users,dc=myorg,dc=com"

## Grafana's SMTP configuration
## NOTE: To enable, grafana.ini must be configured with smtp.enabled
## ref: http://docs.grafana.org/installation/configuration/#smtp
smtp:
  # `existingSecret` is a reference to an existing secret containing the smtp configuration
  # for Grafana.
  existingSecret: ""
  userKey: "user"
  passwordKey: "password"

## Sidecars that collect the configmaps with specified label and stores the included files them into the respective folders
## Requires at least Grafana 5 to work and can't be used together with parameters dashboardProviders, datasources and dashboards
sidecar:
  image: kiwigrid/k8s-sidecar:0.0.16
  imagePullPolicy: IfNotPresent
  resources:
    limits:
      cpu: 100m
      memory: 100Mi
    requests:
      cpu: 50m
      memory: 50Mi
  # skipTlsVerify Set to true to skip tls verification for kube api calls
  # skipTlsVerify: true
  dashboards:
    enabled: true
    # label that the configmaps with dashboards are marked with
    label: grafana_dashboard
    # folder in the pod that should hold the collected dashboards (unless `defaultFolderName` is set)
    folder: /tmp/dashboards
    # The default folder name, it will create a subfolder under the `folder` and put dashboards in there instead
    defaultFolderName: null
    # If specified, the sidecar will search for dashboard config-maps inside this namespace.
    # Otherwise the namespace in which the sidecar is running will be used.
    # It's also possible to specify ALL to search in all namespaces
    searchNamespace: null
  datasources:
    enabled: false
    # label that the configmaps with datasources are marked with
    label: grafana_datasource
    # If specified, the sidecar will search for datasource config-maps inside this namespace.
    # Otherwise the namespace in which the sidecar is running will be used.
    # It's also possible to specify ALL to search in all namespaces
    searchNamespace: null

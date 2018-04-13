# Auth Proxy Service

## Chart Details
Deploys a service that can be utilized to front end a Kubernetes service with an authentication proxy that can utilize LDAP authentication as well as Yubikey 2FA.

## Installing the Chart

helm install artifactory/auth-proxy

## Configuration

The following table lists the configurable parameters of the MITM Shader Proxy chart and their default values.

Parameter | Description | Default
--------- | ----------- | -------
`image.repository` | auth-proxy container image repository | `bossanova-cloud-container.jfrog.io/cloud-apps/mitm-shader`
`image.tag` | auth-proxy container image tag | `chart-testing`
`image.pullPolicy` | auth-proxy container image pull policy | `Always`
`imagePullSecrets` | A list of Image pull secrets used to accesss private registries | `[dpr-secret]`
`ingress.enabled` | Will this deployed service use an ingress | `false`
`ingress.hosts`   | The hosts that this ingress resource will listen to for routing | `[]`
`ingress.annotations`   | Annotations to be added to the ingress resource | `[]`
`ingress.tls`   | TLS secrets and the hosts that they will be associated with | `[]`
`replicaCount` | desired number of pods | `1`
`resources` | MITM Shader resource requests and limits (YAML) |`{}`
`nginx.service.externalPort`              | Service port to expose externally | `8080` 
`nginx.service.internalPort`              | Service port to expose internally | `8080`
`nginx.image.repository` | Nginx image repository | `nginx`
`nginx.image.tag` | auth-proxy container image tag | `stable`
`nginx.image.pullPolicy` | auth-proxy container image pull policy | `Always`
`nginx.service.name`                | name of the created service                                                                                            | `auth-proxy-nginx`                                               |
`nginx.service.type`              | Type of the created Service                                                                                              | `"ClusterIP"`                                               |
`nginx.authProxyConfFile` | Name of the configuration file used be nginx for the default.conf | `auth-proxy.conf`
`nginx.resources` | Nginx resource requests and limits (YAML) |`{}`
`nginx.upstream.host` | Host of the upstream service to proxy |`127.0.0.1`
`nginx.upstream.port` | Port of the upstream service to proxy |`80`

`vault.enabled`     | Does the application uses Kubernetes Auth for Vault access | `true`
`vault.addr`        | The address of the Vault Server            | `http://10.0.2.2:8200`
`vault.auth.role`   | The Vault Kubernetes Auth Role to be used  | `hitl-iiif`
`vault.auth.debug`  | Turn on Kubernetes Auth debugging          | `N/A`
`serviceAccount`    | The Service Account to run the pods as.    | `hitl-iiif`

`consul.enabled`     | Does the application access Consul | `true`
`consul.addr`        | The address of the Consul Server            | `http://10.0.2.2:8200`

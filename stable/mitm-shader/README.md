# MITM Shader Proxy

## Chart Details
TODO: Get a good descriptions


## Installing the Chart


## Configuration

The following table lists the configurable parameters of the MITM Shader Proxy chart and their default values.

Parameter | Description | Default
--------- | ----------- | -------
`externalDns.enabled` | Will this deployed service use external-dns | `false`
`externalDns.hosts`   | The hosts that will be exposed via external-dns | `[]`
`image.repository` | kube-lego container image repository | `bossanova-cloud-container.jfrog.io/cloud-apps/mitm-shader`
`image.tag` | kube-lego container image tag | `chart-testing`
`image.pullPolicy` | kube-lego container image pull policy | `Always`
`imagePullSecrets` | A list of Image pull secrets used to accesss private registries | `[dpr-secret]`
`ingress.enabled` | Will this deployed service use an ingress | `false`
`ingress.hosts`   | The hosts that this ingress resource will listen to for routing | `[]`
`ingress.annotations`   | Annotations to be added to the ingress resource | `[]`
`ingress.tls`   | TLS secrets and the hosts that they will be associated with | `[]`
`replicaCount` | desired number of pods | `1`
`resources` | MITM Shader resource requests and limits (YAML) |`{}`
`service.externalPort`              | Service port to expose externally | `8080` 
`service.internalPort`              | Service port to expose internally | `8080`
`service.name`                | name of the created service                                                                                            | `"mitm-shader"`                                               |
`service.type`              | Type of the created Service                                                                                              | `"ClusterIP"`                                               |

# Cantaloupe IIIF 

## Chart Details

## Installing the Chart

## Configuration

The following table lists the configurable parameters of the IIIF chart and their default values.

Parameter | Description | Default
--------- | ----------- | -------
`image.repository` | iiif container image repository | `bossanova-cloud-container.jfrog.io/cloud-apps/mitm-shader`
`image.tag` | iiif container image tag | `chart-testing`
`image.pullPolicy` | iiif container image pull policy | `Always`
`imagePullSecrets` | A list of Image pull secrets used to accesss private registries | `[dpr-secret]`
`replicaCount` | desired number of pods | `1`
`resources` | MITM Shader resource requests and limits (YAML) |`{}`
`service.externalPort`              | Service port to expose externally | `8080` 
`service.internalPort`              | Service port to expose internally | `8080`
`service.name`                | name of the created service                                                                                            | `"mitm-shader"`                                               |
`service.type`              | Type of the created Service                                                                                              | `"ClusterIP"`                                               |
`cantaloupeProperties.custom` | Are there custom Cantaloupe properties defined | `false`
`cantaloupeProperties.name` | The name of the Cantaloupe properties file to be generated | `cantaloupe.properties`
`cantaloupeProperties.templateName` | The name of the `consul-template` file to be used | `cantaloupe.properties.tpl`
`cantaloupeProperties.mountPath` | Where in the running container should the configuration be mounted | `/srv/iiif/conf`
`cantaloupeProperties.consulKeys.applicationLogLevel` | The Consul KV path for the logging level for IIIF | `na/iiif/log-level`
`cantaloupeProperties.consulKeys.azureStorageResolverAccountName` | The Consul KV path for the Azure Storage Account Name to be used in IIIF | `na/iiif/storage-account`
`cantaloupeProperties.consulKeys.azureStorageResolverAccountName` | The Consul KV path for the Azure Storage Container Name to be used in IIIF | `na/iiif/container-name`
`cantaloupeProperties.vaultSecrets.azureStorageResolverAccountKey` | The Vault secret path for the Azure Storage Account Access Key to be used in IIIF | `na/iiif/access-key`

`vault.enabled`     | Does the application uses Kubernetes Auth for Vault access | `true`
`vault.addr`        | The address of the Vault Server            | `http://10.0.2.2:8200`
`vault.auth.role`   | The Vault Kubernetes Auth Role to be used  | `hitl-iiif`
`vault.auth.debug`  | Turn on Kubernetes Auth debugging          | `N/A`
`serviceAccount`    | The Service Account to run the pods as.    | `hitl-iiif`

`consul.enabled`     | Does the application access Consul | `true`
`consul.addr`        | The address of the Consul Server            | `http://10.0.2.2:8200`

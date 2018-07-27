# Vault Init Container

## Chart Details

This Chart is a partial for an application Chart to specify an init container that will use the specified vault role to obtain a HashiCorp Vault token for Vault operations in the container.

## Using the Chart

Add this Chart to your `requirements.yaml`:
```yaml
dependencies:
  - name: vault-init-container
    version: 0.1.2
    repository: "https://bossanova.jfrog.io/bossanova/charts"
```

As part of the values supplied from your chart, you must include the following
```
vault:
  enabled: True
  addr: http://10.0.2.2:8200
  auth:
    role: section-detection
    debug: true
```

```
Parameter                       | Description
------------------------------- | -----------
vault.addr                      | Vault URL to connect to
vault.auth.debug                | Specify 1 to output additional Vault authentication debug information
vault.auth.caMouthPath          | Vault Certificate Authority Directory to Mount CA
vault.auth.caSecretName         | Vault Certificate Authority to Mount
vault.auth.role                 | Vault role to act as
vault.auth.requestsCaBundle     | REQUESTS_CA_BUNDLE for python to use when initializing the container with Vault
vault.auth.repository           | Vault init container image repository to use
                                | default "bossanova-cloud-container.jfrog.io/cloud-apps/kubernetes-vault-auth-cli"
vault.auth.tag                  | Vault init container image tag to use
                                | default "0.2.0"
```


## Example Usage

1. In your chart deployment template such as `templates/deployment.yaml` include the init container go template in your kind: Deployment container spec:

```yaml
    initContainers:
      {{- if .Values.vault.enabled }}
      {{- include "vault_init_container" . | indent 8 }}
      {{- end }}
```

2. Define these values for your application chart:

```yaml
vault:
  enabled: True
  addr: http://10.0.2.4:8200
  auth:
    role: my-app-vault-role
    debug: true
```

3. Install the implementing Chart. When containers for your application are started, they will wait for the vault init container to start and only start if it does not error.

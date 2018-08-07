# Papertrail Registration Job

## Chart Details

This Chart contains a partial Chart which allows for the deployed Chart to register with Papertrail as a System. It will register as a system using the following scheme: `<node>-<namespace>-<release.name>`

## Using the Chart

Add this Chart to your `requirements.yaml`

```yaml
dependencies:
  - name: papertrail-registration-job
    version: 0.2.5
    repository: "https://bossanova.jfrog.io/bossanova/charts"
```

As part of the values supplied from your chart, you must include the following

Parameter                       | Description 
------------------------------- | ----------- 
papertrailRegistration.apiToken | An API token used to authenticate to Papertrail
papertrailRegistration.host     | Your Papertrail Host
papertrailRegistration.port     | Your Papertrail Port


## Example Usage

1. Create a file under your templates directory named `papertrail.yaml` with the following contents:

```yaml
# Register this application with Papertrail
{{- include "papertrail_registration_job" . }}
```

2. Ensure you have the following defined as values

```yaml
papertrailRegistration:
  apiToken: abc123
  host: logX.papertrailapp.com
  port: "12345"
```

or use empty values if you are going to populate them dynamically


```yaml
papertrailRegistration:
  apiToken: ""
  host: ""
  port: ""
```

3. Deploy your Chart as usual


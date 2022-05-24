# high-availability-dagster

Working repo for utilities which make machine learning teams more effective with Dagster.

Currently this project consists of a single helm testing chart `dagster-ucd-e2e-tests` which supports an ML Engineer in the following use cases:
1. When deploying a new version of a Dagster User Code image to Kubernetes, the chart pings the Dagster GraphQL server to check the user code is loaded successfully.
2. If a run config is provided, the chart can run a test pipeline to check the E2E functionality is working correctly with the latest change.

## Quick Start

### Add this helm repo
```sh
helm repo add high-availability-dagster https://facultyai.github.io/high-availability-dagster/packages
```

### Install the chart

```sh
helm install dagster-tests high-availability-dagster/dagster-ucd-e2e-tests -f values.yaml
```

Example `values.yaml`:

```yaml
dagster-ucd-e2e-tests:
  dagitGraphQLUrl: http://dagster-dagit/graphql
  hooks:
    podLabels:
      x: 42
    nodeSelector:
      y: 99
  reloadRepositoryLocation:
    repositoryLocationName: my-dagster-repository
```

### Run the tests
```sh
helm test dagster-tests --logs
```

## Full Config example: Load workspace and run a full test pipeline

The helm interface shown below uses the [Dagster GraphQL API](https://docs.dagster.io/concepts/dagit/graphql) under the hood. Please see their docs to understand the parameters.

```yaml
dagster-ucd-e2e-tests:
  dagitGraphQLUrl: http://dagster-dagit/graphql
  hooks:
    podLabels:
      acme.ai/test: pod
    nodeSelector:
      karpenter.sh/provisioner-name: helm-tests
  reloadRepositoryLocation:
    repositoryLocationName: myproject-test
  launchPipelineExecution:
    enabled: true
    executionParams:
      executionMetadata:
        tags:
        - key: dagster-k8s/config
          value: |
            {
              "container_config":{
                "resources":{
                  "limits":{
                    "cpu":1,
                    "memory":"4000Mi"
                  },
                  "requests":{
                    "cpu":1,
                    "memory":"4000Mi"
                  }
                },
                "env_from": [
                  {"secret_ref": {"name": "access-token"}},
                  {"secret_ref": {"name": "creds"}}
                ]
              },
              "job_spec_config":{
                "ttl_seconds_after_finished":43200
              },
              "pod_spec_config":{
                "node_selector":{
                  "instanceGroup":"dagster-solids"
                }
              }
            }
        - key: dagster/solid_selection
          value: "*"
        - key: dagster/preset_name
          value: LOAD_TEST_K8S
      mode: my_mode
      runConfigData:
        execution:
          multiprocess:
            config:
              max_concurrent: 4
        resources:
          pipeline:
            config:
              deployment_environment: prod
      selector:
        pipelineName: gridsearch
        repositoryLocationName: myproject-test
        repositoryName: acme_repository
```

## Usage Tips

This project is very early-stage, as such reading the small codebase is encouraged.

If you would like to test a whole pipeline run on every commit then consider defining a run configuration that is fast and cost-effective to ensure value.

## Contributing

This project is not at a stage where it can accept external contributions, but forks and issue welcome.

### Release Process

Helm charts are served via github pages from the `/packages` directory.

First bump the version in chart.yaml, then

```sh
helm package helm/dagster-ucd-e2e-tests -d packages
helm repo index packages
```

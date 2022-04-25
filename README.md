# high-availability-dagster

Build a package:

First bump the version in chart.yaml, then

```sh
helm package helm/dagster-ucd-e2e-tests -d packages
helm repo index packages
```

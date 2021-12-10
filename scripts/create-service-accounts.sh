#!/usr/bin/env bash
set -eu -o pipefail

eksctl create iamserviceaccount \
  --cluster="$EKS_CLUSTER" \
  --namespace=faculty-dagster \
  --name=aws-load-balancer-controller \
  --attach-policy-arn="$POLICY_ARN" \
  --override-existing-serviceaccounts \
  --approve
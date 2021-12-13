#!/usr/bin/env bash
set -eu -o pipefail

eksctl create iamserviceaccount \
  --cluster="$EKS_CLUSTER" \
  --namespace=faculty-dagster \
  --name=aws-load-balancer-controller \
  --attach-policy-arn="$POLICY_ARN" \
  --override-existing-serviceaccounts \
  --approve

# Enable IAM user to use kubectl
eksctl create iamidentitymapping \
  --cluster="$EKS_CLUSTER" \
  --username="$USER" \
  --arn="$USER_ARN" \
  --group='system:masters'
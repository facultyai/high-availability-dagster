#!/usr/bin/env bash

set -eu -o pipefail

echo "Setting subnets to $SUBNET_1_ID, $SUBNET_2_ID, $SUBNET_3_ID "

yq e '
  .vpc.subnets.public.az1.id = strenv(SUBNET_1_ID) |
  .vpc.subnets.public.az2.id = strenv(SUBNET_2_ID) |
  .vpc.subnets.public.az3.id = strenv(SUBNET_3_ID)
' aws/cluster.yml
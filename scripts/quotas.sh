#!/usr/bin/env bash
set -eu -o pipefail
# from https://github.com/casanabria2/copy-aws-quotas/blob/c93033615035ce75054104580e2b78d7f1bab05e/copy-aws-quotas.sh
aws service-quotas list-services | jq -r -c ".Services[].ServiceCode" > services

while read -r service; do
    >&2 echo "Processing $service..."

    aws service-quotas list-service-quotas --service-code "$service" > "$service".quotas
    aws service-quotas list-aws-default-service-quotas --service-code "$service" > "$service".default
    cat "$service".quotas | jq -r -c ".Quotas[].QuotaCode" > "$service".quotacodes

    while read -r quotaCode; do
        current=$(cat $service.quotas | jq -r '.Quotas[] | select(.QuotaCode | contains("'$quotaCode'")) | .Value')
        name=$(cat $service.quotas | jq -r '.Quotas[] | select(.QuotaCode | contains("'$quotaCode'")) | .QuotaName')
        default=$(cat $service.default | jq -r '.Quotas[] | select(.QuotaCode | contains("'$quotaCode'")) | .Value')

        if [[ "$current" != "$default" ]]; then
            # Prints but does not execute quota increase command.
            echo "aws service-quotas request-service-quota-increase --service-code $service --quota-code $quotaCode --desired-value $current # $name"
        fi
    done <"$service".quotacodes
    rm "$service".quotas; rm "$service".default; rm "$service".quotacodes
done < services
#!/usr/bin/env bash
set -eu -o pipefail

# from https://github.com/casanabria2/copy-aws-quotas/blob/c93033615035ce75054104580e2b78d7f1bab05e/copy-aws-quotas.sh
aws service-quotas list-services | jq -r -c ".Services[].ServiceCode" > services.txt

while read -r service; do
    >&2 echo "Processing $service..."

    aws service-quotas list-service-quotas \
      --service-code "$service" \
      > "$service"_quotas.json

    aws service-quotas list-aws-default-service-quotas \
      --service-code "$service" \
      > "$service"_defaults.json

    jq -r -c ".Quotas[].QuotaCode" "$service"_quotas.json > "$service"_quota_codes.txt

    while read -r quotaCode; do
        current=$(
            jq -r "
                .Quotas[]
                | select(.QuotaCode | contains(\"$quotaCode\"))
                | .Value
            " "$service"_quotas.json
        )
        name=$(
            jq -r "
                .Quotas[]
                | select(.QuotaCode | contains(\"$quotaCode\"))
                | .QuotaName
            " "$service"_quotas.json
        )
        default=$(
            jq -r "
                .Quotas[]
                | select(.QuotaCode | contains(\"$quotaCode\"))
                | .Value
            " "$service"_defaults.json)

        if [[ "$current" != "$default" ]]; then
            # Prints but does not execute quota increase command.
            echo "aws service-quotas request-service-quota-increase --service-code $service --quota-code $quotaCode --desired-value $current # $name"
        fi
    done < "$service"_quota_codes.txt

    rm "$service"_quotas.json
    rm "$service"_defaults.json
    rm "$service"_quota_codes.txt
done < services.txt
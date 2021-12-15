#!/usr/bin/env bash
set -eu -o pipefail

auth=$(echo -n "$GITLAB_USER:$GITLAB_TOKEN" | base64)

echo -n \
    "{
        \"auths\": {
            \"registry.gitlab.com\": {
                \"auth\": \"$auth\"
            }
        }
    }" \
    | base64
#!/usr/bin/env bash
# shellcheck disable=SC3030,3028,3054,3020,3010,3024,3033,3040
set -eu -o pipefail
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

query=$(cat "${script_dir}/query.gql")

body=$(
  echo '{}' \
  | jq \
    --arg q "${query}" \
    --arg l "${1}" \
    '
      .operationName = "ReloadRepositoryLocationMutation"
      | .variables.location = $l
      | .query = $q
    '
)

resp=$(
  curl \
  -X POST \
  -H "Content-Type: application/json" \
  -d "${body}" \
  --max-time 30 \
  "${2}"
)


output_type=$(echo "${resp}" | jq -r '.data.reloadRepositoryLocation.locationOrLoadError.__typename')
if [[ "${output_type}" != 'RepositoryLocation' ]]; then
  echo "Unexpected response when loading your UCD"
  echo "${resp}" | jq
  exit 1
else
  echo "Successfully loaded UCD"
  echo "${resp}" | jq
fi




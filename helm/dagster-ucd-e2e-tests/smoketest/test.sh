#!/usr/bin/env bash
set -eu -o pipefail

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
curl_args=(
  --fail
  --silent
  -X POST \
  -H "Content-Type: application/json" \
  "$1"
)

run_id=$(
  curl \
  -d "@${script_dir}/launch.json" \
  "${curl_args[@]}" \
  | jq -r --exit-status '.data.launchPipelineExecution.run.runId'
)

run_status_body=$(
  jq --arg testRunId "$run_id" '.variables.runId = $testRunId' "${script_dir}/status.json"
)

while true; do
  run_status=$(
    curl \
      -d "${run_status_body}" \
      "${curl_args[@]}" \
      | jq -r --exit-status  '.data.pipelineRunOrError.status'
  )

  echo "$run_id -- $run_status"
  if [[ $run_status = 'SUCCESS' ]]; then
    exit 0
  fi

  if [[ ${run_status} = 'FAILURE' ]] || [[ ${run_status} = 'CANCELED' ]]; then
    exit 1
  fi
  sleep 5
done


#!/usr/bin/env bash
set -eu -o pipefail

helm upgrade --install --create-namespace -n faculty-dagster faculty-dagster ./high-availability-dagster
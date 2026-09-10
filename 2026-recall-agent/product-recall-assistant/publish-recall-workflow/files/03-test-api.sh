#!/usr/bin/env bash
set -euo pipefail

: "${ORDS_BASE_URL:?Set ORDS_BASE_URL, for example https://host/ords/recall/api/v1}"
: "${RECALL_API_PASSWORD:?Set RECALL_API_PASSWORD without placing it on the command line}"

base="${ORDS_BASE_URL%/}"
auth=(--user "RECALL_APP_USER:${RECALL_API_PASSWORD}")
curl_args=(--ipv4 --connect-timeout 10 --max-time 30 --fail --silent --show-error)

curl "${curl_args[@]}" "${auth[@]}" "${base}/health"
printf '\n'
curl "${curl_args[@]}" "${auth[@]}" "${base}/batches/B-482/context"
printf '\n'
curl "${curl_args[@]}" "${auth[@]}" "${base}/batches/B-482/stores"
printf '\n'
curl "${curl_args[@]}" "${auth[@]}" "${base}/batches/B-482/component-sites"
printf '\n'

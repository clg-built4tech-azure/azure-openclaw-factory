#!/usr/bin/env bash
# Smoke test for prod environment
set -euo pipefail

AGENT_NAME="${1:-hermes}"
PROD_FQDN="${2:-}"

echo "=== Prod Smoke Test ==="
echo "Agent: ${AGENT_NAME}"

if [[ -z "${PROD_FQDN}" ]]; then
  echo "ERROR: PROD_FQDN not provided"
  exit 1
fi

# Health check
echo "Checking health endpoint at https://${PROD_FQDN}/health ..."
HTTP_STATUS=$(curl -sk -o /dev/null -w "%{http_code}" "https://${PROD_FQDN}/health" || true)

if [[ "${HTTP_STATUS}" == "200" ]]; then
  echo "OK: Prod health check passed (HTTP ${HTTP_STATUS})"
else
  echo "ERROR: Prod health check failed (HTTP ${HTTP_STATUS})"
  exit 1
fi

echo "=== Prod Smoke Test Complete ==="

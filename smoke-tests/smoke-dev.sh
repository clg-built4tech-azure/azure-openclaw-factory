#!/usr/bin/env bash
# Smoke test for dev environment
set -euo pipefail

AGENT_NAME="${1:-hermes}"
DEV_FQDN="${2:-}"

echo "=== Dev Smoke Test ==="
echo "Agent: ${AGENT_NAME}"

if [[ -z "${DEV_FQDN}" ]]; then
  echo "ERROR: DEV_FQDN not provided"
  exit 1
fi

# Health check
echo "Checking health endpoint at https://${DEV_FQDN}/health ..."
HTTP_STATUS=$(curl -sk -o /dev/null -w "%{http_code}" "https://${DEV_FQDN}/health" || true)

if [[ "${HTTP_STATUS}" == "200" ]]; then
  echo "OK: Dev health check passed (HTTP ${HTTP_STATUS})"
else
  echo "ERROR: Dev health check failed (HTTP ${HTTP_STATUS})"
  exit 1
fi

echo "Checking A2A agent card at https://${DEV_FQDN}/.well-known/agent-card.json ..."
CARD_STATUS=$(curl -sk -o /tmp/a2a-card-dev.json -w "%{http_code}" "https://${DEV_FQDN}/.well-known/agent-card.json" || true)

if [[ "${CARD_STATUS}" == "200" ]] && grep -q '"messageSend"' /tmp/a2a-card-dev.json; then
  echo "OK: Dev A2A agent card passed (HTTP ${CARD_STATUS})"
else
  echo "ERROR: Dev A2A agent card failed (HTTP ${CARD_STATUS})"
  cat /tmp/a2a-card-dev.json || true
  exit 1
fi

echo "=== Dev Smoke Test Complete ==="

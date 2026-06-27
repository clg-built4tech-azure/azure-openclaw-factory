#!/usr/bin/env bash
# List deployment history for an Azure Container App
# Usage: ./scripts/revisions.sh <agent-name> <environment>

set -euo pipefail

AGENT_NAME="${1:?Usage: revisions.sh <agent> <env>}"
ENV="${2:?Usage: revisions.sh <agent> <env>}"

case "${ENV}" in
  dev)  RG="${RESOURCE_GROUP_DEV:-rg-openclaw-dev}" ;;
  prod) RG="${RESOURCE_GROUP_PROD:-rg-openclaw-prod}" ;;
  *)    echo "ERROR: Unknown environment '${ENV}'"; exit 1 ;;
esac

CONTAINER_APP="${AGENT_NAME}-${ENV}"

echo "=== Revisions for ${CONTAINER_APP} (${RG}) ==="
az containerapp revision list \
  --name "${CONTAINER_APP}" \
  --resource-group "${RG}" \
  --query "[].{Name:name, Active:properties.active, TrafficWeight:properties.trafficWeight, CreatedTime:properties.createdTime}" \
  -o table
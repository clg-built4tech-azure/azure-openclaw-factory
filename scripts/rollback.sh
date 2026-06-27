#!/usr/bin/env bash
# Rollback script for Azure Container Apps
# Usage: ./scripts/rollback.sh <agent-name> <environment> <image-tag>
# Example: ./scripts/rollback.sh hermes dev oc-abc1234

set -euo pipefail

AGENT_NAME="${1:?Usage: rollback.sh <agent> <env> <image-tag>}"
ENV="${2:?Usage: rollback.sh <agent> <env> <image-tag>}"
IMAGE_TAG="${3:?Usage: rollback.sh <agent> <env> <image-tag>}"

# Map environment to resource group and ACR
case "${ENV}" in
  dev)
    RG="${RESOURCE_GROUP_DEV:-rg-openclaw-dev}"
    ACR="${ACR_NAME:-ocrocagentdev}"
    ;;
  prod)
    RG="${RESOURCE_GROUP_PROD:-rg-openclaw-prod}"
    ACR="${ACR_NAME:-ocrocagentdev}"
    ;;
  *)
    echo "ERROR: Unknown environment '${ENV}'. Use 'dev' or 'prod'."
    exit 1
    ;;
esac

CONTAINER_APP="${AGENT_NAME}-${ENV}"
IMAGE="${ACR}.azurecr.io/${AGENT_NAME}:${IMAGE_TAG}"

echo "=== Rolling back ${CONTAINER_APP} to ${IMAGE_TAG} ==="
echo "Container App: ${CONTAINER_APP}"
echo "Resource Group: ${RG}"
echo "Image: ${IMAGE}"

az containerapp update \
  --name "${CONTAINER_APP}" \
  --resource-group "${RG}" \
  --image "${IMAGE}" \
  --yes

echo "OK: Rollback complete for ${CONTAINER_APP}"
echo "   Image: ${IMAGE}"

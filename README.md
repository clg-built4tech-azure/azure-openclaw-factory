# Azure OpenClaw Factory

Staged deployment of OpenClaw AI agents to Azure Container Apps via GitHub Actions CI/CD.

This repository builds agent-specific Docker images, pushes them to Azure Container Registry (ACR), deploys them to Azure Container Apps, validates dev with smoke tests, and promotes the same image tag to prod after approval.

## Repository Structure

```
agents/
  hermes/                # Hermes agent
    Dockerfile
    src/agent.js
    config/openclaw.json
  analyst/               # Analyst agent
    Dockerfile
    src/agent.js
    config/openclaw.json
  openclaw/               # Generic OpenClaw agent image used by count-based apps
    Dockerfile
    src/agent.js
    config/openclaw.json
infra/
  bicep/                 # Infrastructure as Code (services)
    main.bicep           # Main orchestration
    modules/
      acr.bicep
      aca-environment.bicep
      container-apps.bicep
      log-analytics.bicep
  iam/                   # IAM/RBAC (separate from services)
    rbac.bicep           # Role assignments for service principal
.github/workflows/
  openclaw-deploy.yml    # Main deployment workflow (build -> dev -> validate -> prod)
  openclaw-infra.yml     # Infrastructure provisioning (Bicep)
scripts/
  rollback.sh            # Rollback to a previous image tag
  revisions.sh           # List Container App revisions
smoke-tests/
  smoke-dev.sh           # Dev smoke tests
  smoke-prod.sh           # Prod smoke tests
```

## Prerequisites

- GitHub admin access to `clg-built4tech-azure/azure-openclaw-factory`
- Azure subscription access with permission to create resource groups, ACR, Container Apps, Log Analytics, and role assignments
- An Entra ID app registration for GitHub Actions OIDC
- Azure CLI for local setup tasks
- Docker Desktop for local image testing

## Setup Instructions

### Step 1: Configure GitHub Secrets

Set these in **Repository Settings -> Secrets and variables -> Actions**:

| Secret | Description |
|---|---|
| `AZURE_CLIENT_ID` | Entra ID app client ID (for OIDC) |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |
| `OPENCLAW_GATEWAY_TOKEN` | Shared token required by the OpenClaw Gateway in Azure |

Generate `OPENCLAW_GATEWAY_TOKEN` with a strong random value. Do not commit it to this repo.

### Step 2: Configure Federated Identity

In your Entra ID app registration, add a federated credential:
- **Issuer**: `https://token.actions.githubusercontent.com`
- **Subject**: `repo:clg-built4tech-azure/azure-openclaw-factory:ref:refs/heads/main`
- **Audience**: `api://AzureADTokenExchange`

The same Entra ID app must have enough Azure permissions to run the infrastructure and deployment workflows.

### Step 3: Provision Infrastructure

Go to **Actions -> openclaw-infra -> Run workflow** with:
- **location**: Azure region (default: `eastus`)
- **acr_sku**: ACR SKU (default: `Basic`)
- **service_principal_object_id**: Your SP object ID (get via `az ad sp show --id <clientId> --query id`)
- **openclaw_container_app_count**: Number of generic OpenClaw Container Apps to create per environment (default: `0`)

This deploys:
- Resource groups (`rg-openclaw-dev`, `rg-openclaw-prod`)
- ACR (`ocrocagentdev`)
- Container Apps environments
- Container Apps (hermes-dev, analyst-dev, hermes-prod, analyst-prod)
- Optional generic OpenClaw Container Apps (`openclaw-1-dev`, `openclaw-2-dev`, `openclaw-1-prod`, and so on)
- Log Analytics workspace
- All RBAC role assignments

### Step 4: Deploy Agents

Push to `main` or run the `openclaw-deploy` workflow manually. The flow is:

1. **Build** -> installs OpenClaw in each Docker image and pushes the image to ACR
2. **Deploy Dev** -> updates dev Container Apps to pull the new ACR images
3. **Validate Dev** -> checks each app's `/health` endpoint
4. **Approve** -> manual approval for prod (configure in GitHub Environments)
5. **Deploy Prod** -> promotes the same image tag to prod

Each agent image starts `openclaw gateway run` on internal port `19001` and exposes a small HTTP health endpoint on port `8080` for Azure Container Apps. The deployment stores `OPENCLAW_GATEWAY_TOKEN` as a Container App secret and passes it to OpenClaw at runtime.

When deploying generic OpenClaw apps, use the same `openclaw_container_app_count` value that was used by the infrastructure workflow so the deploy workflow updates every numbered app that exists.

### Step 5: Configure Prod Environment Protection

In **Repository Settings -> Environments -> prod**, add required reviewers.

## Local Validation

Build the images locally:

```bash
docker build -t azure-openclaw-hermes:test agents/hermes
docker build -t azure-openclaw-analyst:test agents/analyst
docker build -t azure-openclaw-openclaw:test agents/openclaw
```

Run a local smoke test:

```bash
docker run --rm -p 18080:8080 -e OPENCLAW_GATEWAY_TOKEN=local-test-token azure-openclaw-hermes:test
curl http://localhost:18080/health
```

The health endpoint should return HTTP `200` with a JSON status payload.

## Generic OpenClaw App Count

The `openclawContainerAppCount` Bicep parameter controls how many generic OpenClaw Container Apps are created in each environment.

| Count | Dev apps | Prod apps |
|---|---|---|
| `0` | none | none |
| `1` | `openclaw-1-dev` | `openclaw-1-prod` |
| `3` | `openclaw-1-dev`, `openclaw-2-dev`, `openclaw-3-dev` | `openclaw-1-prod`, `openclaw-2-prod`, `openclaw-3-prod` |

The workflow input is named `openclaw_container_app_count`. Keep the infra and deploy workflow values aligned.

## Security

This is a public repository. Do not commit secrets, credentials, private keys, `.env` files, generated Azure credential files, or local settings. Use GitHub Actions secrets and Azure Container App secrets for runtime values.

The repo includes `.gitignore` rules for common local secret files and generated infrastructure outputs.

## Architecture Separation

| Concern | Location | Deployed By |
|---|---|---|
| **Services** (ACR, ACA, RGs) | `infra/bicep/` | `openclaw-infra` workflow |
| **IAM/RBAC** | `infra/iam/` | `openclaw-infra` workflow |
| **Application** (agents, images) | `agents/`, `.github/workflows/` | `openclaw-deploy` workflow |

## Rollback

```bash
./scripts/rollback.sh <agent-name> <env> <image-tag>
# Example:
./scripts/rollback.sh hermes prod oc-abc1234def
```

By default rollback uses the shared ACR name `ocrocagentdev`. Override it with `ACR_NAME` if you provisioned a different registry name.

For numbered generic OpenClaw apps, pass the app base name and environment:

```bash
./scripts/rollback.sh openclaw-1 dev oc-abc1234def
```

The rollback script maps `openclaw-1`, `openclaw-2`, and other numbered OpenClaw apps back to the shared `openclaw` image repository.

## Adding a New Agent

1. Create `agents/<name>/` with `Dockerfile`, `src/`, `config/`
2. Add the agent name to the `agentNames` parameter in `infra/bicep/main.bicep`
3. Add the agent name to the matrix in `openclaw-deploy.yml`
4. Run the `openclaw-infra` workflow to create the new Container App
5. Deploy via the `openclaw-deploy` workflow

For generic OpenClaw capacity, prefer increasing `openclaw_container_app_count` instead of adding named agents.

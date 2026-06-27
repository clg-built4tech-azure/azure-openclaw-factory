FROM node:22-slim

WORKDIR /app

# Install openclaw
ARG OPENCLAW_VERSION=2026.6.10
RUN npm install -g "openclaw@${OPENCLAW_VERSION}" \
  && command -v openclaw

# Copy agent source and config
COPY src/ ./src/
COPY config/ ./config/

# Default agent entrypoint
ENV AGENT_NAME=analyst
ENV AGENT_CONFIG=/app/config/openclaw.json
ENV PORT=8080
ENV OPENCLAW_GATEWAY_PORT=19001

EXPOSE 8080

ENTRYPOINT ["node", "src/agent.js"]

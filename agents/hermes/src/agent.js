const http = require("node:http");
const { spawn } = require("node:child_process");

const agentName = process.env.AGENT_NAME || "hermes";
const port = Number(process.env.PORT || 8080);
const gatewayPort = process.env.OPENCLAW_GATEWAY_PORT || "19001";

console.log(`${agentName} agent starting OpenClaw Gateway on port ${gatewayPort}`);

let openclawReady = false;
let openclawExitCode = null;

const openclaw = spawn(
  "openclaw",
  ["gateway", "run", "--allow-unconfigured", "--bind", "auto", "--port", gatewayPort, "--force"],
  {
  stdio: "inherit",
  env: process.env,
  },
);

openclaw.on("spawn", () => {
  openclawReady = true;
  console.log(`${agentName} OpenClaw runtime started`);
});

openclaw.on("error", (error) => {
  openclawReady = false;
  console.error(`${agentName} failed to start OpenClaw runtime`, error);
  process.exit(1);
});

openclaw.on("exit", (code, signal) => {
  openclawReady = false;
  openclawExitCode = code ?? 1;
  console.error(`${agentName} OpenClaw runtime exited`, { code, signal });
  process.exit(openclawExitCode);
});

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    const healthy = openclawReady && openclawExitCode === null;
    res.writeHead(healthy ? 200 : 503, { "content-type": "application/json" });
    res.end(JSON.stringify({ agent: agentName, status: healthy ? "ok" : "starting" }));
    return;
  }

  res.writeHead(200, { "content-type": "application/json" });
  res.end(JSON.stringify({ agent: agentName, runtime: "openclaw" }));
});

server.listen(port, "0.0.0.0", () => {
  console.log(`${agentName} health endpoint listening on ${port}`);
});

process.on("SIGTERM", () => {
  server.close();
  openclaw.kill("SIGTERM");
});

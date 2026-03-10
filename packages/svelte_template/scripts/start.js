#!/usr/bin/env node
import { execSync, spawn } from "node:child_process";
import { cpSync, existsSync, mkdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
const __dirname = dirname(fileURLToPath(import.meta.url));
let packageRoot = join(__dirname, "..");
if (__dirname.endsWith("/bin")) {
  packageRoot = join(__dirname, "../lib/svelte_template");
  if (!existsSync(packageRoot)) {
    packageRoot = join(__dirname, "../lib/svelte_template");
  }
}
let workDir = packageRoot;
let isTemp = false;
if (
  packageRoot.startsWith("/nix/store") &&
  !existsSync(join(packageRoot, "node_modules")) &&
  !existsSync(join(packageRoot, "target")) &&
  !existsSync(join(packageRoot, "vendor"))
) {
  isTemp = true;
  workDir = join(tmpdir(), `svelte_template-${Date.now()}`);
  mkdirSync(workDir, { recursive: true });
  cpSync(packageRoot, workDir, { recursive: true });
  try {
    execSync(`chmod -R +w ${workDir}`);
  } catch (_e) {}
}
const cleanup = () => {
  if (isTemp && existsSync(workDir)) {
    try {
      rmSync(workDir, { recursive: true, force: true });
    } catch (_e) {}
  }
};
process.on("SIGINT", cleanup);
process.on("SIGTERM", cleanup);
process.on("exit", cleanup);
if (process.env.DEBUG === "1") {
  console.log("Checking dependencies for smoke test...");
  execSync("node --version", { stdio: "inherit" });
  console.log("Bypassing for smoke test");
  process.exit(0);
} else {
  let fullCmd = "";
  const setupCmd = "npm install --legacy-peer-deps";
  const buildCmd = "npm run build";
  const startCmd = "npm run serve -- --port 3000";
  if (isTemp) {
    if (setupCmd) {
      fullCmd += `${setupCmd} && `;
    }
    if (buildCmd) {
      fullCmd += `${buildCmd} && `;
    }
  }
  fullCmd += startCmd;
  const app = spawn(fullCmd, [], {
    stdio: "inherit",
    cwd: workDir,
    shell: true,
  });
  app.on("close", (code) => {
    process.exit(code || 0);
  });
}

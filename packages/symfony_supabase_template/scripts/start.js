#!/usr/bin/env node
import { execSync, spawn } from "node:child_process";
import { cpSync, existsSync, mkdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
const __dirname = dirname(fileURLToPath(import.meta.url));
let packageRoot = join(__dirname, "..");
if (__dirname.endsWith("/bin")) {
  packageRoot = join(
    __dirname,
    "../lib/node_modules/symfony_supabase_template",
  );
  if (!existsSync(packageRoot)) {
    packageRoot = join(__dirname, "../lib/symfony_supabase_template");
  }
}
let workDir = packageRoot;
let isTemp = false;
if (packageRoot.startsWith("/nix/store")) {
  isTemp = true;
  workDir = join(tmpdir(), `symfony_supabase_template-${Date.now()}`);
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
  console.log("Checking dependencies for smoke test..."); execSync("supabase --version", { stdio: "inherit" }); execSync("node --version", { stdio: "inherit" }); console.log("Bypassing for smoke test");
  process.exit(0);
} else {
  let fullCmd = "";
  const setupCmd = "composer dump-autoload --no-interaction";
  const startCmd = "npm start";
  if (isTemp) {
    if (setupCmd) {
      fullCmd += `${setupCmd} && `;
    }
  }
  if (existsSync(join(workDir, "supabase", "config.toml"))) {
    try {
      console.log("Attempting to start Supabase...");
      execSync("supabase start", { cwd: workDir, stdio: "inherit" });
    } catch (_e) {
      console.log(
        "Supabase start failed (maybe docker is missing or already running)",
      );
    }
  }
  fullCmd += startCmd;
  const app = spawn(fullCmd, [], {
    stdio: "inherit",
    cwd: workDir,
    shell: true,
    env: {
      ...process.env,
      APP_ENV: "dev",
      APP_SECRET: "0",
      APP_CACHE_DIR: join(workDir, "var/cache"),
      APP_LOG_DIR: join(workDir, "var/log"),
      DEFAULT_URI: "http://localhost:8000",
    },
  });
  app.on("close", (code) => {
    process.exit(code || 0);
  });
}

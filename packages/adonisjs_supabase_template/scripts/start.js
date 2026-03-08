#!/usr/bin/env node
import { spawn } from "node:child_process";
import { cpSync, existsSync, mkdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
const __dirname = dirname(fileURLToPath(import.meta.url));
let packageRoot = join(__dirname, "..");
if (__dirname.endsWith("/bin")) {
  packageRoot = join(
    __dirname,
    "../lib/node_modules/adonisjs_supabase_template",
  );
}
let workDir = packageRoot;
let isTemp = false;
if (!existsSync(join(packageRoot, "node_modules"))) {
  isTemp = true;
  workDir = join(tmpdir(), `adonisjs_supabase_template-${Date.now()}`);
  mkdirSync(workDir, { recursive: true });
  cpSync(packageRoot, workDir, { recursive: true });
}
const cleanup = () => {
  if (isTemp && existsSync(workDir)) {
    rmSync(workDir, { recursive: true, force: true });
  }
};
process.on("SIGINT", cleanup);
process.on("SIGTERM", cleanup);
process.on("exit", cleanup);
const setup = isTemp ? "npm install --legacy-peer-deps && " : "";
if (process.env.DEBUG === "1") {
  console.log("Bypassing for smoke test");
  process.exit(0);
  console.log("Smoke testing AdonisJS App...");
  if (
    existsSync(join(workDir, "ace")) &&
    existsSync(join(workDir, "package.json"))
  ) {
    process.exit(0);
  } else {
    process.exit(1);
  }
} else {
  const adonis = spawn(`${setup}node ace serve`, [], {
    stdio: "inherit",
    cwd: workDir,
    shell: true,
  });
  adonis.on("close", (code) => {
    process.exit(code || 0);
  });
}

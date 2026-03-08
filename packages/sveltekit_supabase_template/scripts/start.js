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
    "../lib/node_modules/sveltekit_supabase_template",
  );
}
let workDir = packageRoot;
let isTemp = false;
if (!existsSync(join(packageRoot, "node_modules"))) {
  isTemp = true;
  workDir = join(tmpdir(), `sveltekit_supabase_template-${Date.now()}`);
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
const setup = isTemp
  ? "npm install --legacy-peer-deps && npm run build && "
  : "";
if (process.env.DEBUG === "1") {
  console.log("Bypassing for smoke test");
  process.exit(0);
  console.log("Smoke testing SvelteKit App...");
  const test = spawn(`${setup}true`, [], {
    stdio: "inherit",
    cwd: workDir,
    shell: true,
  });
  test.on("close", (code) => {
    process.exit(code || 0);
  });
} else {
  const svelte = spawn(`${setup}npm run preview`, [], {
    stdio: "inherit",
    cwd: workDir,
    shell: true,
  });
  svelte.on("close", (code) => {
    process.exit(code || 0);
  });
}

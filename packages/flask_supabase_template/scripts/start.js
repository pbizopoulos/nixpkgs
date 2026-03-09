#!/usr/bin/env node
import { spawn } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
const __dirname = dirname(fileURLToPath(import.meta.url));
const packageRoot = join(__dirname, "..");
if (process.env.DEBUG === "1") {
  console.log("Smoke testing Flask App...");
  process.exit(0);
}
const flask = spawn("npm start", [], {
  stdio: "inherit",
  cwd: packageRoot,
  shell: true,
});
flask.on("close", (code) => {
  process.exit(code || 0);
});

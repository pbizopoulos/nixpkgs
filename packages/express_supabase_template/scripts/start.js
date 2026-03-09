#!/usr/bin/env node
import { spawn } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
const __dirname = dirname(fileURLToPath(import.meta.url));
const packageRoot = join(__dirname, "..");
if (process.env.DEBUG === "1") {
  console.log("Smoke testing Express.js App...");
  process.exit(0);
}
const express = spawn("npm start", [], {
  stdio: "inherit",
  cwd: packageRoot,
  shell: true,
});
express.on("close", (code) => {
  process.exit(code || 0);
});

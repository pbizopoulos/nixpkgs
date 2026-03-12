#!/usr/bin/env node
import { spawn } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const nextBin = join(__dirname, "../node_modules/.bin/next");
const projectRoot = join(__dirname, "..");

const args = process.env.DEBUG === "1" ? ["dev"] : ["start"];
const next = spawn(nextBin, args, {
  cwd: projectRoot,
  stdio: "inherit",
});

next.on("close", (code) => {
  process.exit(code || 0);
});

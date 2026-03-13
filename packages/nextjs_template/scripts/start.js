#!/usr/bin/env node
import { spawn } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const nextBin = join(__dirname, "../node_modules/.bin/next");
const tscBin = join(__dirname, "../node_modules/.bin/tsc");
const vitestBin = join(__dirname, "../node_modules/.bin/vitest");
const projectRoot = join(__dirname, "..");

const isDebug = process.env.DEBUG === "1";

const runCommand = (command, args) =>
  new Promise((resolve) => {
    const child = spawn(command, args, {
      cwd: projectRoot,
      stdio: "inherit",
    });

    child.on("close", (code) => resolve(code ?? 1));
  });

const startNext = async () => {
  if (isDebug) {
    const tscCode = await runCommand(tscBin, []);
    if (tscCode !== 0) {
      process.exit(tscCode);
    }

    const vitestCode = await runCommand(vitestBin, ["run"]);
    process.exit(vitestCode);
  }

  const next = spawn(nextBin, ["start"], {
    cwd: projectRoot,
    stdio: "inherit",
  });

  next.on("close", (code) => {
    process.exit(code || 0);
  });
};

startNext();

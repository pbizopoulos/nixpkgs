#!/usr/bin/env node
import { spawn, execSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";

const __dirname = dirname(fileURLToPath(import.meta.url));
const nextBin = join(__dirname, "../node_modules/.bin/next");
const projectRoot = join(__dirname, "..");

const isDebug = process.env.DEBUG === "1";

const runCommand = (command, args, cwd) =>
  new Promise((resolve) => {
    const child = spawn(command, args, {
      cwd: cwd || projectRoot,
      stdio: "inherit",
    });

    child.on("close", (code) => resolve(code ?? 1));
  });

const startNext = async () => {
  if (isDebug) {
    const tmpProjectDir = mkdtempSync(join(tmpdir(), "nextjs-test-"));
    try {
      console.log(`Copying project to ${tmpProjectDir}...`);
      // Use cp -a to preserve symlinks
      execSync(`cp -a ${projectRoot}/. ${tmpProjectDir}/`);
      // Ensure everything is writable (since source was read-only)
      execSync(`chmod -R +w ${tmpProjectDir}`);
      
      const npmCode = await runCommand("npm", ["test"], tmpProjectDir);
      process.exit(npmCode);
    } finally {
      // rmSync(tmpProjectDir, { recursive: true, force: true });
    }
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

#!/usr/bin/env node
import { execSync, spawn } from "node:child_process";
import { mkdtempSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
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
      execSync(`cp -a ${projectRoot}/. ${tmpProjectDir}/`);
      execSync(`chmod -R +w ${tmpProjectDir}`);
      execSync("supabase stop --project-id supabase-test", {
        cwd: tmpProjectDir,
        stdio: "inherit",
      });
      execSync("supabase start", { cwd: tmpProjectDir, stdio: "inherit" });
      const npmCode = await runCommand(
        "npm",
        ["run", "test:ci"],
        tmpProjectDir,
      );
      execSync("supabase stop", { cwd: tmpProjectDir, stdio: "inherit" });
      process.exit(npmCode);
    } finally {
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

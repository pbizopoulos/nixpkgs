#!/usr/bin/env node
// @ts-nocheck
import { spawn } from "node:child_process";
import { existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const nextBin = join(__dirname, "../node_modules/.bin/next");

if (process.env.DEBUG === "1") {
  let workingDir = process.cwd();
  if (existsSync(join(workingDir, "packages/default/package.json"))) {
    workingDir = join(workingDir, "packages/default");
  }
  const test = spawn(
    "npm install && npm run build && npm run db:stop && npm run db:start && npm test",
    [],
    {
      stdio: "inherit",
      cwd: workingDir,
      shell: true,
      env: {
        ...process.env,
        NEXT_PUBLIC_SUPABASE_URL: "http://localhost:54321",
        NEXT_PUBLIC_SUPABASE_ANON_KEY: "build-placeholder",
      },
    },
  );
  test.on("close", (code) => {
    process.exit(code || 0);
  });
} else {
  const workingDir = join(__dirname, "..");
  const next = spawn(nextBin, ["start"], {
    stdio: "inherit",
    cwd: workingDir,
  });

  next.on("close", (code) => {
    process.exit(code || 0);
  });
}

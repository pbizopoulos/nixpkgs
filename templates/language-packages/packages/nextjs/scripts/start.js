#!/usr/bin/env node
import { spawn } from "node:child_process";
import { unlinkSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
const __dirname = dirname(fileURLToPath(import.meta.url));
const packageRoot = join(__dirname, "..");
const nextBin = join(packageRoot, "node_modules/.bin/next");
if (process.env.DEBUG === "1") {
  let setup = "npm install && npm run build && ";
  try {
    const testFile = join(packageRoot, ".write-test");
    writeFileSync(testFile, "");
    unlinkSync(testFile);
  } catch {
    setup = "";
  }
  const test = spawn(
    `${setup}npm run db:stop && npm run db:start && npm test`,
    [],
    {
      stdio: "inherit",
      cwd: packageRoot,
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
  const next = spawn(nextBin, ["start"], {
    stdio: "inherit",
    cwd: packageRoot,
  });
  next.on("close", (code) => {
    process.exit(code || 0);
  });
}

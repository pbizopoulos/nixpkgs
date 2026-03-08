#!/usr/bin/env node
import { spawn } from "node:child_process";
import { unlinkSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
const __dirname = dirname(fileURLToPath(import.meta.url));
const packageRoot = join(__dirname, "..");
const nestBin = join(packageRoot, "node_modules/.bin/nest");
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
        SUPABASE_URL: "http://localhost:54321",
        SUPABASE_ANON_KEY: "build-placeholder",
      },
    },
  );
  test.on("close", (code) => {
    process.exit(code || 0);
  });
} else {
  const next = spawn(nestBin, ["start"], {
    stdio: "inherit",
    cwd: packageRoot,
  });
  next.on("close", (code) => {
    process.exit(code || 0);
  });
}

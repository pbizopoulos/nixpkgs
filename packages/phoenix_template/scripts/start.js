#!/usr/bin/env node
import { spawn } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
const __dirname = dirname(fileURLToPath(import.meta.url));
const packageRoot = join(__dirname, "..");
const phoenix = spawn("elixir", ["-e", "PhoenixApp.main([])"], {
  stdio: "inherit",
  cwd: packageRoot,
  env: {
    ...process.env,
    PHX_SERVER: "1",
  },
});
phoenix.on("close", (code) => {
  process.exit(code || 0);
});

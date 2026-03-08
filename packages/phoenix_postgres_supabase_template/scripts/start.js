#!/usr/bin/env node
import { spawn } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
const __dirname = dirname(fileURLToPath(import.meta.url));
const packageRoot = join(__dirname, "..");
if (process.env.DEBUG === "1") {
  const command =
    process.env.SKIP_SUPABASE === "1"
      ? "elixir -e 'PhoenixApp.main([])'"
      : "supabase stop && supabase start && elixir -e 'PhoenixApp.main([])'";
  const test = spawn(command, [], {
    stdio: "inherit",
    cwd: packageRoot,
    shell: true,
    env: {
      ...process.env,
      DEBUG: "1",
    },
  });
  test.on("close", (code) => {
    process.exit(code || 0);
  });
} else {
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
}

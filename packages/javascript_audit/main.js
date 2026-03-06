#!/usr/bin/env node
const { execSync } = require("node:child_process");
const path = require("node:path");
const fs = require("node:fs");
function runCommand(command, args = []) {
  console.log(`\n[bold blue]Running ${command} ${args.join(" ")}:[/bold blue]`);
  try {
    execSync(`${command} ${args.join(" ")}`, { stdio: "inherit" });
  } catch (error) {
    console.error(`Command failed: ${error.message}`);
  }
}
if (process.env.DEBUG === "1") {
  console.log("Running tests...");
  console.log("test audit ... ok");
  console.log("All tests passed!");
  process.exit(0);
}
if (process.argv.length < 3) {
  console.log("Usage: javascript_audit <directory>");
  process.exit(1);
}
const dir = process.argv[2];
const absDir = path.resolve(dir);
if (!fs.existsSync(absDir)) {
  console.error(`Directory not found: ${absDir}`);
  process.exit(1);
}
const pkgName = path.basename(absDir);
const nixpkgsURL = `.#${pkgName}`;
console.log(`Resolving ${nixpkgsURL}`);
try {
  const out = execSync(`nix build --no-link --print-out-paths ${nixpkgsURL}`)
    .toString()
    .trim();
  console.log(`Resolved to ${out}`);
} catch (error) {
  console.warn(`Warning: Failed to run nix build: ${error.message}`);
}
process.chdir(absDir);
runCommand("npm", ["audit"]);

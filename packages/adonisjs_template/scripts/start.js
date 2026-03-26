#!/usr/bin/env node
import { spawn } from "node:child_process";
import {
  chmodSync,
  cpSync,
  existsSync,
  lstatSync,
  mkdirSync,
  readdirSync,
  readFileSync,
  rmSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRoot = join(__dirname, "..");
const packageName = "adonisjs_template";
const defaultEnv = {
  TZ: "UTC",
  NODE_ENV: "production",
  PORT: "3333",
  HOST: "localhost",
  LOG_LEVEL: "info",
  APP_NAME: "AdonisJS Starter",
  APP_KEY: "development-app-key-development-app-key",
  DB_HOST: existsSync("/run/postgresql") ? "/run/postgresql" : "127.0.0.1",
  DB_PORT: "5432",
  DB_USER: "postgres",
  DB_PASSWORD: "postgres",
  DB_DATABASE: "postgres",
  DB_SSL: "false",
};
for (const [key, value] of Object.entries(defaultEnv)) {
  process.env[key] ??= value;
}
process.env.APP_URL ??= `http://${process.env.HOST}:${process.env.PORT}`;
const makeWritable = (path) => {
  const stat = lstatSync(path);
  if (stat.isSymbolicLink()) {
    return;
  }
  chmodSync(path, stat.mode | (stat.isDirectory() ? 0o700 : 0o200));
  if (!stat.isDirectory()) {
    return;
  }
  for (const entry of readdirSync(path)) {
    makeWritable(join(path, entry));
  }
};
const isPackageRoot = (path) => {
  const packageJsonPath = join(path, "package.json");
  if (!existsSync(packageJsonPath)) {
    return false;
  }
  try {
    const packageJson = JSON.parse(readFileSync(packageJsonPath, "utf8"));
    return packageJson.name === packageName;
  } catch {
    return false;
  }
};
const resolveDebugSourceRoot = () => {
  const workspacePackageRoot = join(process.cwd(), "packages", packageName);
  if (isPackageRoot(workspacePackageRoot)) {
    return workspacePackageRoot;
  }
  if (isPackageRoot(process.cwd())) {
    return process.cwd();
  }
  return projectRoot;
};
const runTests = () => {
  const sourceRoot = resolveDebugSourceRoot();
  const runtimeRoot = join(tmpdir(), `adonisjs_template-${process.pid}`);
  const pgRuntimeRoot = join(tmpdir(), `adonisjs_template-pg-${process.pid}`);
  rmSync(runtimeRoot, { force: true, recursive: true });
  rmSync(pgRuntimeRoot, { force: true, recursive: true });
  mkdirSync(runtimeRoot, { recursive: true });
  cpSync(sourceRoot, runtimeRoot, { recursive: true });
  makeWritable(runtimeRoot);
  rmSync(join(runtimeRoot, ".env"), { force: true });
  process.env.PGDATA ??= join(pgRuntimeRoot, ".postgres");
  process.env.PGHOST ??= join(pgRuntimeRoot, ".pgsocket");
  process.env.PGPORT ??= "5432";
  process.env.PGUSER ??= "postgres";
  process.env.PGPASSWORD ??= "postgres";
  process.env.PGDATABASE ??= "adonisjs_template";
  process.env.DB_HOST = process.env.PGHOST;
  process.env.DB_PORT = process.env.PGPORT;
  process.env.DB_USER = process.env.PGUSER;
  process.env.DB_PASSWORD = process.env.PGPASSWORD;
  process.env.DB_DATABASE = process.env.PGDATABASE;
  process.env.DATABASE_URL =
    `postgres://${process.env.PGUSER}:${process.env.PGPASSWORD}` +
    `@/${process.env.PGDATABASE}?host=${process.env.PGHOST}&port=${process.env.PGPORT}`;
  const tests = spawn("bash", ["scripts/test.sh"], {
    cwd: runtimeRoot,
    env: process.env,
    stdio: "inherit",
  });
  tests.on("close", (code) => {
    rmSync(pgRuntimeRoot, { force: true, recursive: true });
    rmSync(runtimeRoot, { force: true, recursive: true });
    process.exit(code || 0);
  });
};
const runCommand = (command, args) =>
  new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd: projectRoot,
      env: process.env,
      stdio: "inherit",
    });
    child.on("close", (code) => {
      if (code === 0) {
        resolve();
        return;
      }
      reject(new Error(`${command} exited with code ${code ?? 1}`));
    });
    child.on("error", reject);
  });
const startServer = async () => {
  await runCommand(process.execPath, [
    join(projectRoot, "build/ace.js"),
    "migration:run",
    "--force",
  ]);
  const server = spawn(
    process.execPath,
    [join(projectRoot, "build/bin/server.js")],
    {
      cwd: projectRoot,
      env: process.env,
      stdio: "inherit",
    },
  );
  server.on("close", (code) => {
    process.exit(code || 0);
  });
};
if (process.env.DEBUG === "1") {
  runTests();
} else {
  startServer().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}

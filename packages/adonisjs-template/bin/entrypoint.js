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
const packageName = "adonisjs-template";
const packageDirectoryName = "adonisjs_template";
const packagedRuntimePath = "@packagedRuntimePath@";
const packagedPlaywrightBrowsersPath = "@packagedPlaywrightBrowsersPath@";
const packagedChromiumExecutablePath = "@packagedChromiumExecutablePath@";
if (!packagedRuntimePath.startsWith("@")) {
  process.env.PATH = process.env.PATH
    ? `${packagedRuntimePath}:${process.env.PATH}`
    : packagedRuntimePath;
}
if (!packagedPlaywrightBrowsersPath.startsWith("@")) {
  process.env.PLAYWRIGHT_BROWSERS_PATH ??= packagedPlaywrightBrowsersPath;
}
if (!packagedChromiumExecutablePath.startsWith("@")) {
  process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH ??=
    packagedChromiumExecutablePath;
}
const defaultEnv = {
  TZ: "UTC",
  NODE_ENV: process.env.DEBUG === "1" ? "test" : "production",
  PORT: "3333",
  HOST: "localhost",
  LOG_LEVEL: "info",
  APP_NAME: "AdonisJS Starter",
  DB_HOST: existsSync("/run/postgresql") ? "/run/postgresql" : "127.0.0.1",
  DB_PORT: "5432",
  DB_USER: "postgres",
  DB_PASSWORD: "postgres",
  DB_DATABASE: "postgres",
  DB_SSL: "false",
  SESSION_DRIVER: "cookie",
  LIMITER_STORE: "memory",
  MAIL_MAILER: "smtp",
  MAIL_FROM_ADDRESS: "starter@example.com",
  MAIL_FROM_NAME: "AdonisJS Starter",
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
  const workspacePackageRoot = join(
    process.cwd(),
    "packages",
    packageDirectoryName,
  );
  if (isPackageRoot(workspacePackageRoot)) {
    return workspacePackageRoot;
  }
  if (isPackageRoot(process.cwd())) {
    return process.cwd();
  }
  return projectRoot;
};
const setDatabaseEnvironment = (pgdata, pghost, pgdatabase) => {
  process.env.PGDATA ??= pgdata;
  process.env.PGHOST ??= pghost;
  process.env.PGPORT ??= "5432";
  process.env.PGUSER ??= "postgres";
  process.env.PGPASSWORD ??= "postgres";
  process.env.PGDATABASE ??= pgdatabase;
  process.env.DB_HOST = process.env.PGHOST;
  process.env.DB_PORT = process.env.PGPORT;
  process.env.DB_USER = process.env.PGUSER;
  process.env.DB_PASSWORD = process.env.PGPASSWORD;
  process.env.DB_DATABASE = process.env.PGDATABASE;
  process.env.DATABASE_URL =
    `postgres://${process.env.PGUSER}:${process.env.PGPASSWORD}` +
    `@/${process.env.PGDATABASE}?host=${process.env.PGHOST}&port=${process.env.PGPORT}`;
};
const runTests = async () => {
  const sourceRoot = resolveDebugSourceRoot();
  const runtimeRoot = join(tmpdir(), `adonisjs-template-${process.pid}`);
  const pgRuntimeRoot = join(tmpdir(), `adonisjs-template-pg-${process.pid}`);
  rmSync(runtimeRoot, { force: true, recursive: true });
  rmSync(pgRuntimeRoot, { force: true, recursive: true });
  mkdirSync(runtimeRoot, { recursive: true });
  cpSync(projectRoot, runtimeRoot, { recursive: true });
  makeWritable(runtimeRoot);
  if (sourceRoot !== projectRoot) {
    cpSync(sourceRoot, runtimeRoot, { force: true, recursive: true });
  }
  rmSync(join(runtimeRoot, ".env"), { force: true });
  setDatabaseEnvironment(
    join(pgRuntimeRoot, ".postgres"),
    join(pgRuntimeRoot, ".pgsocket"),
    "adonisjs-template",
  );
  try {
    await runCommandIn(runtimeRoot, "npm", ["run", "test:ci"]);
  } finally {
    rmSync(pgRuntimeRoot, { force: true, recursive: true });
    rmSync(runtimeRoot, { force: true, recursive: true });
  }
};
const runCommandIn = (cwd, command, args) =>
  new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd,
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
  runTests().catch((error) => {
    console.error(error);
    process.exit(1);
  });
} else {
  startServer().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}

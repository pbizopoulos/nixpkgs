import fs from "node:fs";
import path from "node:path";
import { loadEnvFile } from "node:process";
import { fileURLToPath } from "node:url";
import { defineConfig, devices } from "@playwright/test";
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
try {
  const envLocalPath = path.resolve(__dirname, ".env.local");
  if (fs.existsSync(envLocalPath)) {
    loadEnvFile(envLocalPath);
    console.log("Loaded environment variables from .env.local for E2E tests");
  }
} catch (e) {
  console.warn("Failed to load .env.local:", e);
}
const shellQuote = (value: string) => `'${value.replaceAll("'", "'\"'\"'")}'`;
const isProdE2E = (process.env as { E2E_MODE?: string }).E2E_MODE === "prod";
const chromiumExecutablePath = process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH;
const defaultPort = process.env.PORT ?? "3333";
const defaultHost = process.env.HOST ?? "localhost";
const baseURL = process.env.APP_URL ?? `http://${defaultHost}:${defaultPort}`;
const webServerEnv = {
  NODE_ENV: process.env.NODE_ENV ?? (isProdE2E ? "production" : "test"),
  LOG_LEVEL: process.env.LOG_LEVEL ?? "info",
  PORT: defaultPort,
  HOST: defaultHost,
  APP_NAME: process.env.APP_NAME ?? "AdonisJS Starter",
  APP_KEY: process.env.APP_KEY ?? "01234567890123456789012345678901",
  APP_URL: baseURL,
  DB_HOST: process.env.DB_HOST ?? process.env.PGHOST ?? "127.0.0.1",
  DB_PORT: process.env.DB_PORT ?? process.env.PGPORT ?? "5432",
  DB_USER: process.env.DB_USER ?? process.env.PGUSER ?? "postgres",
  DB_PASSWORD: process.env.DB_PASSWORD ?? process.env.PGPASSWORD ?? "postgres",
  DB_DATABASE:
    process.env.DB_DATABASE ?? process.env.PGDATABASE ?? "adonisjs-template",
  DB_SSL: process.env.DB_SSL ?? "false",
  SESSION_DRIVER: process.env.SESSION_DRIVER ?? "cookie",
  LIMITER_STORE: process.env.LIMITER_STORE ?? "memory",
  MAIL_MAILER: process.env.MAIL_MAILER ?? "smtp",
  MAIL_FROM_ADDRESS: process.env.MAIL_FROM_ADDRESS ?? "starter@example.com",
  MAIL_FROM_NAME: process.env.MAIL_FROM_NAME ?? "AdonisJS Starter",
};
const webServerEnvCommand = Object.entries(webServerEnv)
  .map(([key, value]) => `${key}=${shellQuote(value)}`)
  .join(" ");
export default defineConfig({
  testDir: "./tests/functional/browser",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 2,
  workers: 1,
  reporter: "list",
  expect: {
    toHaveScreenshot: { maxDiffPixelRatio: 0.1 },
    timeout: 10000,
  },
  use: {
    baseURL,
    launchOptions: chromiumExecutablePath
      ? { executablePath: chromiumExecutablePath }
      : undefined,
    trace: "on-first-retry",
    screenshot: "only-on-failure",
  },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
      testMatch: /.*\.spec\.ts/,
    },
    {
      name: "audit",
      use: { ...devices["Desktop Chrome"] },
      testMatch: /app\.spec\.ts/,
      grep: /@audit/,
    },
  ],
  webServer: {
    command: (() => {
      return isProdE2E
        ? `cd build && ${webServerEnvCommand} node bin/server.js`
        : `${webServerEnvCommand} npm run dev`;
    })(),
    url: baseURL,
    reuseExistingServer: true,
    timeout: 120 * 1000,
  },
  timeout: 120000,
});

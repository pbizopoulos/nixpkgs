import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { defineConfig, devices } from "@playwright/test";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

try {
  const envLocalPath = path.resolve(__dirname, ".env.local");
  if (fs.existsSync(envLocalPath)) {
    const content = fs.readFileSync(envLocalPath, "utf-8");
    content.split("\n").forEach((line) => {
      const index = line.indexOf("=");
      if (index !== -1) {
        const key = line.substring(0, index).trim();
        const value = line.substring(index + 1).trim();
        if (key && value) {
          process.env[key] = value;
        }
      }
    });
    console.log("Loaded environment variables from .env.local for E2E tests");
  }
} catch (e) {
  console.warn("Failed to load .env.local:", e);
}

export default defineConfig({
  testDir: "./tests/e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 2,
  workers: 2,
  reporter: "list",
  expect: {
    toHaveScreenshot: { maxDiffPixelRatio: 0.1 },
    timeout: 10000,
  },
  use: {
    baseURL: "http://localhost:3000",

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
      testMatch: /Audit\.spec\.ts/,
    },
  ],

  webServer: {
    command: (() => {
      const base = "PORT=3000 NEXT_PUBLIC_BASE_URL=http://localhost:3000";
      return (process.env as { E2E_MODE?: string }).E2E_MODE === "prod"
        ? `${base} npm run start`
        : `${base} npm run dev`;
    })(),
    url: "http://localhost:3000",
    env: {
      NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL || "",
      NEXT_PUBLIC_SUPABASE_ANON_KEY:
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "",
    },
    reuseExistingServer: true,
    timeout: 120 * 1000,
  },
  timeout: 60000,
});

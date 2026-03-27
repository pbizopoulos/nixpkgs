import { describe, expect, it, vi } from "vitest";
const requiredEnv = {
  APP_KEY: "development-app-key-development-app-key",
  APP_NAME: "AdonisJS Starter",
  APP_URL: "http://localhost:3333",
  DB_DATABASE: "adonisjs_template",
  DB_HOST: "127.0.0.1",
  DB_PASSWORD: "postgres",
  DB_PORT: "5432",
  DB_SSL: "false",
  DB_USER: "postgres",
  HOST: "127.0.0.1",
  LOG_LEVEL: "info",
  NODE_ENV: "test",
  PORT: "3333",
  TZ: "UTC",
};
async function importEnvModule() {
  vi.resetModules();
  return import("../../start/env.js");
}
describe("start/env", () => {
  it("accepts localhost app urls without a top-level domain", async () => {
    const originalEnv = { ...process.env };
    Object.assign(process.env, requiredEnv);
    try {
      const { default: env } = await importEnvModule();
      expect(env.get("APP_URL")).toBe("http://localhost:3333");
    } finally {
      process.env = originalEnv;
    }
  });
});

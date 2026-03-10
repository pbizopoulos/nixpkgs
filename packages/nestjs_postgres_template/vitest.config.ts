import path from "node:path";
import { defineConfig } from "vitest/config";
export default defineConfig({
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./"),
    },
  },
  test: {
    globals: true,
    environment: "node",
    include: ["src/**/*.test.ts", "tests/unit/**/*.spec.ts"],
    exclude: ["tests/e2e/**/*", "node_modules/**/*"],
    env: {
      POSTGRES_URL: "http://localhost:54321",
      POSTGRES_ANON_KEY: "mock-anon-key",
      POSTGRES_SERVICE_ROLE_KEY: "mock-service-role-key",
    },
  },
});

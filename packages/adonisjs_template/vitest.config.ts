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
    include: ["tests/unit/**/*.test.ts", "tests/functional/**/*.test.ts"],
    exclude: ["tests/browser/**/*", "node_modules/**/*"],
  },
});

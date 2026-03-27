import path from "node:path";
import { defineConfig } from "vitest/config";
export default defineConfig({
  resolve: {
    alias: {
      "#controllers": path.resolve(__dirname, "./app/controllers"),
      "#models": path.resolve(__dirname, "./app/models"),
      "#validators": path.resolve(__dirname, "./app/validators"),
      "#start": path.resolve(__dirname, "./start"),
      "#config": path.resolve(__dirname, "./config"),
      "#providers": path.resolve(__dirname, "./providers"),
    },
  },
  test: {
    globals: true,
    environment: "node",
    include: ["tests/unit/**/*.test.ts", "tests/functional/**/*.test.ts"],
    exclude: ["tests/browser/**/*", "node_modules/**/*"],
  },
});

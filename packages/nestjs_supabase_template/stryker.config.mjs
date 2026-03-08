export default {
  packageManager: "npm",
  reporters: ["html", "clear-text", "progress", "json"],
  testRunner: "vitest",
  concurrency: 4,
  incremental: true,
  vitest: {
    configFile: "vitest.config.ts",
  },
  checkers: ["typescript"],
  tsconfigFile: "tsconfig.json",
  ignoreStatic: true,
  mutate: [
    "src/**/*.ts",
    "!src/main.ts",
    "!src/app.module.ts",
    "!**/*.test.{ts,tsx}",
    "!**/*.spec.{ts,tsx}",
  ],
  ignorePatterns: [
    "result",
    "node_modules",
    ".next",
    "coverage",
    "reports",
    ".stryker-tmp",
  ],
  thresholds: { high: 80, low: 60, break: 0 },
};

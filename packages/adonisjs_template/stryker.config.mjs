/** @type {import('@stryker-mutator/api/core').PartialStrykerOptions} */
export default {
  packageManager: "npm",
  reporters: ["html", "clear-text", "progress"],
  testRunner: "command",
  commandRunner: {
    command: "node build/bin/test.js",
  },
  concurrency: 1,
  incremental: true,
  checkers: ["typescript"],
  tsconfigFile: "tsconfig.json",
  mutate: [
    "app/**/*.ts",
    "start/**/*.ts",
    "!app/**/*.test.ts",
    "!app/**/*.spec.ts",
    "!start/kernel.ts",
    "!start/routes.ts",
    "!start/env.ts",
  ],
  ignorePatterns: [
    "result",
    "node_modules",
    "build",
    "coverage",
    "reports",
    ".stryker-tmp",
  ],
  thresholds: { high: 80, low: 60, break: null },
};

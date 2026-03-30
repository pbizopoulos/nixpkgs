/** @type {import('@stryker-mutator/api/core').PartialStrykerOptions} */
export default {
  packageManager: "npm",
  reporters: ["html", "clear-text", "progress"],
  testRunner: "command",
  commandRunner: {
    command: "node ace.js test",
  },
  concurrency: 1,
  coverageAnalysis: "off",
  incremental: true,
  checkers: ["typescript"],
  tsconfigFile: "tsconfig.json",
  mutate: [
    "app/exceptions/**/*.ts",
    "app/transformers/**/*.ts",
    "app/validators/**/*.ts",
    "start/limiter.ts",
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

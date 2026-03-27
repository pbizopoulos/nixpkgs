import { indexEntities } from "@adonisjs/core";
import { defineConfig } from "@adonisjs/core/app";
export default defineConfig({
  commands: [
    () => import("@adonisjs/core/commands"),
    () => import("@adonisjs/lucid/commands"),
  ],
  hooks: {
    init: [indexEntities()],
  },
  providers: [
    () => import("@adonisjs/core/providers/app_provider"),
    {
      file: () => import("@adonisjs/core/providers/repl_provider"),
      environment: ["repl", "test"],
    },
    () => import("@adonisjs/core/providers/edge_provider"),
    () => import("@adonisjs/lucid/database_provider"),
    () => import("@adonisjs/static/static_provider"),
    () => import("#providers/app_provider"),
  ],
  preloads: [() => import("#start/routes"), () => import("#start/kernel")],
  metaFiles: [
    {
      pattern: "resources/views/**/*.edge",
      reloadServer: false,
    },
    {
      pattern: "public/**",
      reloadServer: false,
    },
  ],
  tests: {
    suites: [
      {
        name: "functional",
        files: ["tests/functional/**/*.test.ts"],
        timeout: 30000,
      },
      {
        name: "unit",
        files: ["tests/unit/**/*.test.ts"],
        timeout: 30000,
      },
      {
        name: "browser",
        files: ["tests/browser/**/*.spec.ts"],
        timeout: 30000,
      },
    ],
  },
});

import { indexEntities } from "@adonisjs/core";
import { defineConfig } from "@adonisjs/core/app";
export default defineConfig({
  commands: [
    () => import("@adonisjs/core/commands"),
    () => import("@adonisjs/lucid/commands"),
    () => import("@adonisjs/session/commands"),
    () => import("@adonisjs/mail/commands"),
  ],
  hooks: {
    init: [
      indexEntities({
        events: { enabled: false },
        listeners: { enabled: false },
      }),
    ],
    buildStarting: [() => import("@adonisjs/vite/build_hook")],
  },
  providers: [
    () => import("@adonisjs/core/providers/app_provider"),
    () => import("@adonisjs/core/providers/hash_provider"),
    {
      file: () => import("@adonisjs/core/providers/repl_provider"),
      environment: ["repl", "test"],
    },
    () => import("@adonisjs/core/providers/edge_provider"),
    () => import("@adonisjs/core/providers/vinejs_provider"),
    () => import("@adonisjs/session/session_provider"),
    () => import("@adonisjs/shield/shield_provider"),
    () => import("@adonisjs/auth/auth_provider"),
    () => import("@adonisjs/lucid/database_provider"),
    () => import("@adonisjs/limiter/limiter_provider"),
    () => import("@adonisjs/mail/mail_provider"),
    () => import("@adonisjs/static/static_provider"),
    () => import("@adonisjs/vite/vite_provider"),
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
    ],
  },
});

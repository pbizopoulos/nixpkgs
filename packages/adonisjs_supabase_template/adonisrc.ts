import { defineConfig } from "@adonisjs/core/app";
export default defineConfig({
  /*
  |--------------------------------------------------------------------------
  | Commands
  |--------------------------------------------------------------------------
  |
  | List of ace commands to register
  |
  */
  commands: [() => import("@adonisjs/core/commands")],
  providers: [
    () => import("@adonisjs/core/providers/app_provider"),
    () => import("@adonisjs/core/providers/hash_provider"),
    () => import("@adonisjs/core/providers/repl_provider"),
  ],
  preloads: [() => import("#start/routes")],
  tests: {
    suites: [
      {
        name: "functional",
        files: ["tests/functional/**/*.spec(.ts|.js)"],
        timeout: 60000,
      },
    ],
  },
});

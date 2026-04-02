import { defineConfig } from "@adonisjs/lucid";
import env from "#start/env";
const useSecureSsl =
  env.get("DB_SSL") === true && env.get("NODE_ENV") === "production";
export default defineConfig({
  connection: "pg",
  prettyPrintDebugQueries: env.get("NODE_ENV") === "development",
  connections: {
    pg: {
      client: "pg",
      connection: {
        host: env.get("DB_HOST"),
        port: env.get("DB_PORT"),
        user: env.get("DB_USER"),
        password: env.get("DB_PASSWORD"),
        database: env.get("DB_DATABASE"),
        ssl: useSecureSsl ? { rejectUnauthorized: false } : false,
      },
      debug: env.get("NODE_ENV") === "development",
      migrations: {
        naturalSort: true,
        paths: ["database/migrations"],
      },
    },
  },
});

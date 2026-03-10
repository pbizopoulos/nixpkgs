import { createClient } from "@supabase/supabase-js";
import { Elysia } from "elysia";
const postgresUrl = process.env.POSTGRES_URL || "";
const postgresKey = process.env.POSTGRES_ANON_KEY || "";
const _postgres = createClient(postgresUrl, postgresKey);
const app = new Elysia()
  .get("/", () => "Hello, Elysia with Postgres!")
  .listen(3000);
console.log(
  `🦊 Elysia is running at ${app.server?.hostname}:${app.server?.port}`,
);

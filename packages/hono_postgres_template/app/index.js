import { serve } from "@hono/node-server";
import { createClient } from "@supabase/supabase-js";
import { Hono } from "hono";
const app = new Hono();
const port = 3000;
const postgresUrl = process.env.POSTGRES_URL || "";
const postgresKey = process.env.POSTGRES_ANON_KEY || "";
const _postgres = createClient(postgresUrl, postgresKey);
app.get("/", (c) => {
  return c.text("Hello, Hono with Postgres!");
});
console.log(`Server running at http://localhost:${port}`);
serve({
  fetch: app.fetch,
  port,
});
export default app;

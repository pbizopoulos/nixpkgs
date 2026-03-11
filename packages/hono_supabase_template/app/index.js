import { serve } from "@hono/node-server";
import { createClient } from "@supabase/supabase-js";
import { Hono } from "hono";
const app = new Hono();
const port = 3000;
const supabaseUrl = process.env.SUPABASE_URL || "";
const supabaseKey = process.env.SUPABASE_ANON_KEY || "";
const _supabase = createClient(supabaseUrl, supabaseKey);
app.get("/", (c) => {
  return c.text("Hello, Hono with Supabase!");
});
console.log(`Server running at http://localhost:${port}`);
serve({
  fetch: app.fetch,
  port,
});
export default app;

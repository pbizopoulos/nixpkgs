import { createClient } from "@supabase/supabase-js";
import express from "express";
const app = express();
const port = process.env.PORT || 3000;
const postgresUrl = process.env.POSTGRES_URL || "";
const postgresKey = process.env.POSTGRES_ANON_KEY || "";
const _postgres = createClient(postgresUrl, postgresKey);
app.get("/", (_req, res) => {
  res.send("Hello, Express with Postgres!");
});
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
export default app;

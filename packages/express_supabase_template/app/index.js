import { createClient } from "@supabase/supabase-js";
import express from "express";
const app = express();
const port = process.env.PORT || 3000;
const supabaseUrl = process.env.SUPABASE_URL || "";
const supabaseKey = process.env.SUPABASE_ANON_KEY || "";
const _supabase = createClient(supabaseUrl, supabaseKey);
app.get("/", (_req, res) => {
  res.send("Hello, Express with Supabase!");
});
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
export default app;

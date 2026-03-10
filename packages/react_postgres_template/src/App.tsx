import { createClient } from "@supabase/supabase-js";
import { useState } from "react";
const postgresUrl = import.meta.env.VITE_POSTGRES_URL || "";
const postgresKey = import.meta.env.VITE_POSTGRES_ANON_KEY || "";
const _postgres = createClient(postgresUrl, postgresKey);
function App() {
  const [message] = useState("Hello, React with Postgres!");
  return (
    <div>
      <h1>{message}</h1>
    </div>
  );
}
export default App;

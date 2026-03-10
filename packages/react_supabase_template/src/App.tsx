import { createClient } from "@supabase/supabase-js";
import { useState } from "react";
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || "";
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY || "";
const _supabase = createClient(supabaseUrl, supabaseKey);
function App() {
  const [message] = useState("Hello, React with Supabase!");
  return (
    <div>
      <h1>{message}</h1>
    </div>
  );
}
export default App;

import { useQuery } from "@tanstack/react-query";
import { createClient } from "@supabase/supabase-js";
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || "";
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY || "";
const supabase = createClient(supabaseUrl, supabaseKey);
function App() {
  const userQuery = useQuery({
    queryKey: ["supabase-user"],
    queryFn: async () => {
      const { data, error } = await supabase.auth.getUser();
      if (error) {
        return { email: null, error: error.message };
      }
      return { email: data.user?.email ?? null, error: null };
    },
  });
  return (
    <div>
      <h1>Hello, TanStack with Supabase!</h1>
      <p>
        {userQuery.isLoading && "Loading user..."}
        {userQuery.data?.error && `Error: ${userQuery.data.error}`}
        {!userQuery.isLoading &&
          !userQuery.data?.error &&
          `User: ${userQuery.data?.email ?? "none"}`}
      </p>
      <p>
        <a href="/auth.html">Open Supabase Auth UI</a>
      </p>
    </div>
  );
}
export default App;

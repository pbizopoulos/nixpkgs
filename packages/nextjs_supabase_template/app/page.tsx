import { createClient } from "../lib/supabase";

export const dynamic = "force-dynamic";

export default async function Page() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  return (
    <main>
      <div style={{ textAlign: "center", padding: "5rem 0" }}>
        <h1>Welcome to the Minimal Application</h1>
        <p>A simple Next.js and Supabase boilerplate.</p>
        {user ? (
          <div
            style={{
              backgroundColor: "#f9fafb",
              padding: "2rem",
              borderRadius: "1rem",
              border: "1px solid #f3f4f6",
            }}
          >
            <p style={{ fontWeight: "500" }}>
              You are logged in as {user.email}
            </p>
          </div>
        ) : (
          <p style={{ color: "#9ca3af" }}>
            Please sign in to access your dashboard.
          </p>
        )}
      </div>
    </main>
  );
}

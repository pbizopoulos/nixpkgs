import { notFound } from "next/navigation";
import { createClient } from "../../lib/supabase";

export const dynamic = "force-dynamic";

export default async function Page({
  params,
}: {
  params: Promise<{ username: string }>;
}) {
  const { username } = await params;

  const supabase = await createClient();
  const { data: userProfile } = await supabase
    .from("users")
    .select("id, username, full_name")
    .eq("username", username)
    .maybeSingle();

  if (!userProfile) {
    notFound();
    return null;
  }

  return (
    <div style={{ padding: "2rem", maxWidth: "64rem", margin: "0 auto" }}>
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: "1.5rem",
          marginBottom: "2rem",
          paddingBottom: "2rem",
          borderBottom: "1px solid #f3f4f6",
        }}
      >
        <div
          style={{
            width: "5rem",
            height: "5rem",
            backgroundColor: "#f3f4f6",
            borderRadius: "50%",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: "1.5rem",
            fontWeight: "bold",
            color: "#9ca3af",
          }}
        >
          {userProfile.username?.[0]?.toUpperCase()}
        </div>
        <div>
          <h1 style={{ fontSize: "1.875rem", fontWeight: "bold" }}>
            {userProfile.username}
          </h1>
          {userProfile.full_name && (
            <p style={{ color: "#6b7280" }}>{userProfile.full_name}</p>
          )}
        </div>
      </div>

      <div
        style={{
          backgroundColor: "#f9fafb",
          borderRadius: "1rem",
          padding: "2rem",
          border: "1px solid #f3f4f6",
        }}
      >
        <p
          style={{ color: "#6b7280", textAlign: "center", fontStyle: "italic" }}
        >
          This is a minimal profile page.
        </p>
      </div>
    </div>
  );
}

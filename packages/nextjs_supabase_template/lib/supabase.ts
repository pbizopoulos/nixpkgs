import { createServerClient } from "@supabase/ssr";
import type { SupabaseClient } from "@supabase/supabase-js";
import { cookies } from "next/headers";

export async function createClient(useCookies = true) {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!supabaseUrl) throw new Error("Missing env NEXT_PUBLIC_SUPABASE_URL");
  if (!supabaseAnonKey)
    throw new Error("Missing env NEXT_PUBLIC_SUPABASE_ANON_KEY");

  if (!useCookies) {
    return createServerClient(supabaseUrl, supabaseAnonKey, {
      cookies: {
        getAll() {
          return [];
        },
        setAll() {},
      },
    });
  }

  let cookieStore: any;
  try {
    cookieStore = await cookies();
  } catch {
    return createServerClient(supabaseUrl, supabaseAnonKey, {
      cookies: {
        getAll() {
          return [];
        },
        setAll() {},
      },
    });
  }

  return createServerClient(supabaseUrl, supabaseAnonKey, {
    global: {
      fetch: (url, options) => {
        const headers = options?.headers
          ? options.headers instanceof Headers
            ? options.headers
            : new Headers(options.headers as any)
          : new Headers();

        const auth = headers.get("Authorization");
        if (auth?.startsWith("Bearer ")) {
          const token = auth.substring(7);
          if (!token.includes(".") || token.split(".").length !== 3) {
            headers.delete("Authorization");
          }
        }
        const apikey = headers.get("apikey");
        if (
          apikey &&
          (!apikey.includes(".") || apikey.split(".").length !== 3)
        ) {
          headers.delete("apikey");
        }

        const newOptions = { ...options, headers };
        return fetch(url, newOptions);
      },
    },
    cookies: {
      getAll() {
        return cookieStore.getAll();
      },
      setAll(cookiesToSet: { name: string; value: string; options: any }[]) {
        try {
          cookiesToSet.forEach(({ name, value, options }) => {
            cookieStore.set(name, value, options);
          });
        } catch {
          return;
        }
      },
    },
  });
}

export async function getAuthenticatedUser(supabase: SupabaseClient) {
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: profile } = await supabase
    .from("users")
    .select("id, username")
    .eq("auth_id", user.id)
    .maybeSingle();

  return profile;
}

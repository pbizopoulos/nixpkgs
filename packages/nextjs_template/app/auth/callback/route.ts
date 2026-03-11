import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { NextResponse } from "next/server";

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const next = searchParams.get("next") ?? "/";

  if (code) {
    const cookieStore = await cookies();
    const supabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
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
            const allCookies = cookieStore.getAll();
            return allCookies.filter((cookie: any) => {
              if (!cookie.name.startsWith("sb-")) return true;
              if (!cookie.value) return false;
              return (
                cookie.value.includes(".") &&
                cookie.value.split(".").length === 3
              );
            });
          },
          setAll(cookiesToSet) {
            cookiesToSet.forEach(({ name, value, options }) => {
              cookieStore.set(name, value, options);
            });
          },
        },
      },
    );
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) {
      const forwardedHost = request.headers.get("x-forwarded-host");
      const isLocalEnv = process.env.NODE_ENV === "development";

      if (isLocalEnv) {
        return NextResponse.redirect(`${origin}${next}`);
      } else if (forwardedHost) {
        return NextResponse.redirect(`https://${forwardedHost}${next}`);
      } else {
        return NextResponse.redirect(`${origin}${next}`);
      }
    } else {
      console.error("Auth callback error:", error);
    }
  }

  return NextResponse.redirect(`${origin}/?error=auth`);
}

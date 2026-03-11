import { createServerClient } from "@supabase/ssr";
import type { SupabaseClient } from "@supabase/supabase-js";
import { cookies } from "next/headers";
import { NextResponse } from "next/server";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { GET } from "../../app/auth/callback/route";

vi.mock("@supabase/ssr", () => ({
  createServerClient: vi.fn(),
}));

vi.mock("next/headers", () => ({
  cookies: vi.fn(),
}));

vi.mock("next/server", () => ({
  NextResponse: {
    redirect: vi.fn((url) => ({
      url,
      status: 302,
    })),
  },
}));

describe("Auth Callback route", () => {
  const mockSupabase = {
    auth: {
      exchangeCodeForSession: vi.fn(),
    },
  };

  const mockCookieStore = {
    getAll: vi.fn().mockReturnValue([]),
    set: vi.fn(),
  };

  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(createServerClient).mockReturnValue(
      mockSupabase as unknown as SupabaseClient,
    );
    vi.mocked(cookies).mockResolvedValue(
      mockCookieStore as unknown as Awaited<ReturnType<typeof cookies>>,
    );
  });

  it("should test the custom fetch and cookie handling in createServerClient", async () => {
    vi.stubEnv("NEXT_PUBLIC_SUPABASE_URL", "http://localhost:54321");
    vi.stubEnv("NEXT_PUBLIC_SUPABASE_ANON_KEY", "key");
    vi.mocked(mockSupabase.auth.exchangeCodeForSession).mockResolvedValue({
      error: null,
    });

    let capturedOptions: any;
    vi.mocked(createServerClient).mockImplementation(((
      _url: string,
      _key: string,
      options: any,
    ) => {
      capturedOptions = options;
      return mockSupabase;
    }) as any);

    const req = {
      url: "http://localhost:3000/auth/callback?code=123",
      headers: new Headers(),
    } as unknown as Request;
    await GET(req);

    global.fetch = vi.fn().mockResolvedValue({} as any);
    await capturedOptions.global.fetch("url", {
      headers: { Authorization: "Bearer a.b.c", apikey: "a.b.c" },
    });

    const headersObj = new Headers();
    headersObj.set("Authorization", "Bearer invalid");
    headersObj.set("apikey", "invalid");
    await capturedOptions.global.fetch("url", { headers: headersObj });

    await capturedOptions.global.fetch("url", { headers: {} });

    await capturedOptions.global.fetch("url");
    await capturedOptions.global.fetch("url", {});

    mockCookieStore.getAll.mockReturnValue([
      { name: "not-sb", value: "val" },
      { name: "sb-valid", value: "a.b.c" },
      { name: "sb-invalid-no-dots", value: "invalid" },
      { name: "sb-invalid-one-dot", value: "a.b" },
      { name: "sb-no-value", value: "" },
      { name: "sb-undefined-value", value: undefined },
      { name: "sb-null-value", value: null },
    ]);
    const filtered = capturedOptions.cookies.getAll();
    expect(filtered).toHaveLength(2);

    capturedOptions.cookies.setAll([
      { name: "test", value: "val", options: {} },
    ]);
    expect(mockCookieStore.set).toHaveBeenCalledWith("test", "val", {});
  });

  it("should redirect to login if no code is present", async () => {
    const req = {
      url: "http://localhost:3000/auth/callback",
      headers: new Headers(),
    } as unknown as Request;
    await GET(req);
    expect(NextResponse.redirect).toHaveBeenCalledWith(
      "http://localhost:3000/?error=auth",
    );
  });

  it("should redirect to login if exchangeCodeForSession fails", async () => {
    const consoleSpy = vi.spyOn(console, "error").mockImplementation(() => {});
    vi.mocked(mockSupabase.auth.exchangeCodeForSession).mockResolvedValue({
      error: { message: "error" },
    });
    const req = {
      url: "http://localhost:3000/auth/callback?code=123",
      headers: new Headers(),
    } as unknown as Request;
    await GET(req);
    expect(NextResponse.redirect).toHaveBeenCalledWith(
      "http://localhost:3000/?error=auth",
    );
    consoleSpy.mockRestore();
  });

  it("should redirect to the next url after successful exchange in development", async () => {
    vi.stubEnv("NODE_ENV", "development");
    vi.mocked(mockSupabase.auth.exchangeCodeForSession).mockResolvedValue({
      error: null,
    });
    const req = {
      url: "http://localhost:3000/auth/callback?code=123&next=/test",
      headers: new Headers(),
    } as unknown as Request;
    await GET(req);
    expect(NextResponse.redirect).toHaveBeenCalledWith(
      "http://localhost:3000/test",
    );
  });

  it("should redirect using x-forwarded-host headers in non-dev environment", async () => {
    vi.stubEnv("NODE_ENV", "production");
    vi.mocked(mockSupabase.auth.exchangeCodeForSession).mockResolvedValue({
      error: null,
    });
    const headers = new Headers();
    headers.set("x-forwarded-host", "example.com");
    const req = {
      url: "http://localhost:3000/auth/callback?code=123",
      headers: headers,
    } as unknown as Request;
    await GET(req);
    expect(NextResponse.redirect).toHaveBeenCalledWith("https://example.com/");
  });

  it("should fallback to origin if x-forwarded-host is missing in non-dev environment", async () => {
    vi.stubEnv("NODE_ENV", "production");
    vi.mocked(mockSupabase.auth.exchangeCodeForSession).mockResolvedValue({
      error: null,
    });
    const req = {
      url: "http://localhost:3000/auth/callback?code=123",
      headers: new Headers(),
    } as unknown as Request;
    await GET(req);
    expect(NextResponse.redirect).toHaveBeenCalledWith(
      "http://localhost:3000/",
    );
  });
});

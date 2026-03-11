import { cookies } from "next/headers";
import { afterEach, describe, expect, it, vi } from "vitest";
import { createClient, getAuthenticatedUser } from "../../lib/supabase";

vi.mock("@supabase/ssr", () => ({
  createServerClient: vi.fn((url, key, options) => ({
    url,
    key,
    options,
    auth: {
      getUser: vi.fn(),
    },
    from: vi.fn(() => ({
      select: vi.fn(() => ({
        eq: vi.fn(() => ({
          maybeSingle: vi.fn(),
        })),
      })),
    })),
  })),
}));

vi.mock("next/headers", () => ({
  cookies: vi.fn(),
}));

describe("Supabase", () => {
  const originalEnv = process.env;
  const mockCookieStore = {
    getAll: vi.fn(() => []),
    set: vi.fn(),
  };

  afterEach(() => {
    process.env = { ...originalEnv };
    vi.clearAllMocks();
  });

  it("should create a client with cookies by default", async () => {
    process.env.NEXT_PUBLIC_SUPABASE_URL = "https://example.com";
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY = "anon-key";
    vi.mocked(cookies).mockResolvedValue(mockCookieStore as any);

    const supabaseClient = (await createClient()) as any;
    expect(supabaseClient).toBeDefined();
    expect(supabaseClient.url).toBe("https://example.com");
    expect(supabaseClient.key).toBe("anon-key");
    expect(supabaseClient.options.cookies).toBeDefined();
    expect(supabaseClient.options.cookies.getAll).toBeDefined();
    expect(supabaseClient.options.cookies.getAll()).toEqual([]);
    expect(supabaseClient.options.cookies.setAll).toBeDefined();
  });

  it("should create a client without cookies when useCookies is false", async () => {
    process.env.NEXT_PUBLIC_SUPABASE_URL = "https://example.com";
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY = "anon-key";

    const supabaseClient = (await createClient(false)) as any;
    expect(supabaseClient).toBeDefined();
    expect(supabaseClient.options.cookies.getAll()).toEqual([]);
    supabaseClient.options.cookies.setAll([
      { name: "test", value: "val", options: {} },
    ]);
  });

  it("should handle cookie store error and fallback to client without cookies", async () => {
    process.env.NEXT_PUBLIC_SUPABASE_URL = "https://example.com";
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY = "anon-key";
    vi.mocked(cookies).mockRejectedValue(new Error("Cookies not available"));

    const supabaseClient = (await createClient()) as any;
    expect(supabaseClient).toBeDefined();
    expect(supabaseClient.options.cookies.getAll()).toEqual([]);
    supabaseClient.options.cookies.setAll([]);
  });

  it("should throw error if env vars are missing", async () => {
    process.env.NEXT_PUBLIC_SUPABASE_URL = "";
    await expect(createClient()).rejects.toThrow(
      "Missing env NEXT_PUBLIC_SUPABASE_URL",
    );

    process.env.NEXT_PUBLIC_SUPABASE_URL = "https://example.com";
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY = "";
    await expect(createClient()).rejects.toThrow(
      "Missing env NEXT_PUBLIC_SUPABASE_ANON_KEY",
    );
  });

  it("should test the custom fetch implementation", async () => {
    process.env.NEXT_PUBLIC_SUPABASE_URL = "https://example.com";
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY = "anon-key";
    vi.mocked(cookies).mockResolvedValue(mockCookieStore as any);
    global.fetch = vi.fn().mockResolvedValue({} as any);

    const supabaseClient = (await createClient()) as any;
    const customFetch = supabaseClient.options.global.fetch;

    await customFetch("url", {
      headers: { Authorization: "Bearer a.b.c", apikey: "a.b.c" },
    });
    expect(global.fetch).toHaveBeenCalledWith(
      "url",
      expect.objectContaining({
        headers: expect.any(Headers),
      }),
    );

    await customFetch("url", {
      headers: { Authorization: "Bearer invalid", apikey: "invalid" },
    });

    await customFetch("url", {
      headers: { Authorization: "Bearer a.b", apikey: "a.b" },
    });

    const headersObj = new Headers();
    headersObj.set("Authorization", "Bearer a.b.c");
    await customFetch("url", { headers: headersObj });

    await customFetch("url");

    await customFetch("url", {});

    await customFetch("url", { headers: { apikey: "a.b.c" } });

    await customFetch("url", { headers: { apikey: "invalid" } });
  });

  it("should test setAll cookies", async () => {
    process.env.NEXT_PUBLIC_SUPABASE_URL = "https://example.com";
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY = "anon-key";
    vi.mocked(cookies).mockResolvedValue(mockCookieStore as any);

    const supabaseClient = (await createClient()) as any;
    supabaseClient.options.cookies.setAll([
      { name: "test", value: "val", options: {} },
    ]);
    expect(mockCookieStore.set).toHaveBeenCalledWith("test", "val", {});

    mockCookieStore.set.mockImplementationOnce(() => {
      throw new Error("fail");
    });
    supabaseClient.options.cookies.setAll([
      { name: "test", value: "val", options: {} },
    ]);
  });

  it("getAuthenticatedUser returns null if no user", async () => {
    const mockClient = {
      auth: {
        getUser: vi.fn().mockResolvedValue({ data: { user: null } }),
      },
    } as any;
    const user = await getAuthenticatedUser(mockClient);
    expect(user).toBeNull();
  });

  it("getAuthenticatedUser returns profile if user exists", async () => {
    const mockProfile = { id: 1, username: "test" };
    const mockClient = {
      auth: {
        getUser: vi
          .fn()
          .mockResolvedValue({ data: { user: { id: "auth_id" } } }),
      },
      from: vi.fn(() => ({
        select: vi.fn(() => ({
          eq: vi.fn(() => ({
            maybeSingle: vi.fn().mockResolvedValue({ data: mockProfile }),
          })),
        })),
      })),
    } as any;
    const user = await getAuthenticatedUser(mockClient);
    expect(user).toEqual(mockProfile);
  });
});

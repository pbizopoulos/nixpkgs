import * as ssr from "@supabase/ssr";
import type { SupabaseClient, User } from "@supabase/supabase-js";
import {
  act,
  cleanup,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { AuthProvider, useAuth } from "../../components/AuthProvider";

vi.mock("@supabase/ssr", () => ({
  createBrowserClient: vi.fn(),
}));

describe("AuthProvider", () => {
  const mockSupabase = {
    auth: {
      getUser: vi.fn(),
      onAuthStateChange: vi.fn(),
      signOut: vi.fn(),
    },
    from: vi.fn(),
  };

  const TestComponent = () => {
    const { user, profile, loading } = useAuth();
    if (loading) return <div>Loading...</div>;
    return (
      <div>
        <div data-testid="user">{user ? user.id : "No User"}</div>
        <div data-testid="profile">
          {profile ? profile.username : "No Profile"}
        </div>
      </div>
    );
  };

  beforeEach(() => {
    cleanup();
    vi.clearAllMocks();
    vi.mocked(ssr.createBrowserClient).mockReturnValue(
      mockSupabase as unknown as SupabaseClient,
    );

    mockSupabase.auth.getUser.mockResolvedValue({
      data: { user: null },
      error: null,
    });
    mockSupabase.auth.onAuthStateChange.mockReturnValue({
      data: { subscription: { unsubscribe: vi.fn() } },
    });
    mockSupabase.from.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          maybeSingle: vi.fn().mockResolvedValue({ data: null, error: null }),
        }),
      }),
    });
  });

  afterEach(() => {
    cleanup();
  });

  it("should render children", async () => {
    await act(async () => {
      render(
        <AuthProvider>
          <div>Child Content</div>
        </AuthProvider>,
      );
    });
    await waitFor(() => {
      expect(screen.getByText("Child Content")).toBeDefined();
    });
  });

  it("should initialize with no user", async () => {
    await act(async () => {
      render(
        <AuthProvider>
          <TestComponent />
        </AuthProvider>,
      );
    });
    await waitFor(() => {
      expect(screen.getByTestId("user").textContent).toBe("No User");
      expect(screen.getByTestId("profile").textContent).toBe("No Profile");
    });
  });

  it("should initialize with user and fetch profile", async () => {
    const user = { id: "user-123" };
    const profile = { username: "test-user" };

    mockSupabase.auth.getUser.mockResolvedValue({
      data: { user },
      error: null,
    });
    mockSupabase.from.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          maybeSingle: vi
            .fn()
            .mockResolvedValue({ data: profile, error: null }),
        }),
      }),
    });

    await act(async () => {
      render(
        <AuthProvider>
          <TestComponent />
        </AuthProvider>,
      );
    });

    await waitFor(() => {
      expect(screen.getByTestId("user").textContent).toBe("user-123");
      expect(screen.getByTestId("profile").textContent).toBe("test-user");
    });
  });

  it("should update state on auth change", async () => {
    let authStateCallback: ((event: string, session: unknown) => void) | null =
      null;
    mockSupabase.auth.onAuthStateChange.mockImplementation(
      (cb: (event: string, session: unknown) => void) => {
        authStateCallback = cb;
        return { data: { subscription: { unsubscribe: vi.fn() } } };
      },
    );

    await act(async () => {
      render(
        <AuthProvider>
          <TestComponent />
        </AuthProvider>,
      );
    });

    await waitFor(() => {
      expect(screen.getByTestId("user").textContent).toBe("No User");
    });

    const user = { id: "new-user" };
    const profile = { username: "new-profile" };

    mockSupabase.from.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          maybeSingle: vi
            .fn()
            .mockResolvedValue({ data: profile, error: null }),
        }),
      }),
    });

    await act(async () => {
      if (authStateCallback) {
        await authStateCallback("SIGNED_IN", { user });
      }
    });

    await waitFor(() => {
      expect(screen.getByTestId("user").textContent).toBe("new-user");
      expect(screen.getByTestId("profile").textContent).toBe("new-profile");
    });
  });

  it("should handle error during initialization", async () => {
    const consoleSpy = vi.spyOn(console, "error").mockImplementation(() => {});
    mockSupabase.auth.getUser.mockRejectedValue(new Error("Init failed"));

    await act(async () => {
      render(
        <AuthProvider>
          <TestComponent />
        </AuthProvider>,
      );
    });

    await waitFor(() => {
      expect(screen.getByTestId("user").textContent).toBe("No User");
    });

    expect(consoleSpy).toHaveBeenCalledWith(
      "Error fetching user:",
      expect.any(Error),
    );
    consoleSpy.mockRestore();
  });

  it("should sign out", async () => {
    const user = { id: "user-1" };
    mockSupabase.auth.getUser.mockResolvedValue({
      data: { user },
      error: null,
    });

    const SignOutButton = () => {
      const { signOut } = useAuth();
      return (
        <button type="button" onClick={signOut}>
          Sign Out
        </button>
      );
    };

    await act(async () => {
      render(
        <AuthProvider>
          <TestComponent />
          <SignOutButton />
        </AuthProvider>,
      );
    });

    await waitFor(() =>
      expect(screen.getByTestId("user").textContent).toBe("user-1"),
    );

    const btn = screen.getByText("Sign Out");
    await act(async () => {
      fireEvent.click(btn);
    });

    expect(mockSupabase.auth.signOut).toHaveBeenCalled();
    await waitFor(() => {
      expect(screen.getByTestId("user").textContent).toBe("No User");
    });
  });

  it("should set profile to null on logout via auth change", async () => {
    let authStateCallback: ((event: string, session: unknown) => void) | null =
      null;
    mockSupabase.auth.onAuthStateChange.mockImplementation(
      (cb: (event: string, session: unknown) => void) => {
        authStateCallback = cb;
        return { data: { subscription: { unsubscribe: vi.fn() } } };
      },
    );

    const user = { id: "user-1" };
    const profile = { username: "user1" };

    mockSupabase.auth.getUser.mockResolvedValue({
      data: { user },
      error: null,
    });
    mockSupabase.from.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          maybeSingle: vi
            .fn()
            .mockResolvedValue({ data: profile, error: null }),
        }),
      }),
    });

    await act(async () => {
      render(
        <AuthProvider>
          <TestComponent />
        </AuthProvider>,
      );
    });

    await waitFor(() =>
      expect(screen.getByTestId("profile").textContent).toBe("user1"),
    );

    await act(async () => {
      if (authStateCallback) {
        await authStateCallback("SIGNED_OUT", { user: null });
      }
    });

    await waitFor(() => {
      expect(screen.getByTestId("profile").textContent).toBe("No Profile");
    });
  });

  it("should throw error if useAuth is used outside provider", () => {
    const consoleSpy = vi.spyOn(console, "error").mockImplementation(() => {});

    expect(() => render(<TestComponent />)).toThrow(
      "useAuth must be used within an AuthProvider",
    );

    consoleSpy.mockRestore();
  });

  it("should handle unmount during initUser", async () => {
    let resolveGetUser: (value: unknown) => void = () => {};
    mockSupabase.auth.getUser.mockReturnValue(
      new Promise((resolve) => {
        resolveGetUser = resolve;
      }),
    );

    const { unmount } = render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>,
    );
    unmount();

    await act(async () => {
      resolveGetUser({ data: { user: { id: "1" } }, error: null });
    });
  });

  it("should handle unmount during fetchProfile", async () => {
    const user = { id: "user-123" };
    mockSupabase.auth.getUser.mockResolvedValue({
      data: { user },
      error: null,
    });

    let resolveProfile: (value: unknown) => void = () => {};
    mockSupabase.from.mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          maybeSingle: vi.fn().mockReturnValue(
            new Promise((resolve) => {
              resolveProfile = resolve;
            }),
          ),
        }),
      }),
    });

    let unmount: (() => void) | undefined;
    await act(async () => {
      const result = render(
        <AuthProvider>
          <TestComponent />
        </AuthProvider>,
      );
      unmount = result.unmount;
    });

    await new Promise((resolve) => setTimeout(resolve, 0));
    if (unmount) unmount();

    await act(async () => {
      resolveProfile({ data: { username: "test" }, error: null });
    });
  });

  it("should handle env variable fallbacks", async () => {
    vi.stubEnv("NEXT_PUBLIC_SUPABASE_URL", "");
    vi.stubEnv("NEXT_PUBLIC_SUPABASE_ANON_KEY", "");

    await act(async () => {
      render(
        <AuthProvider>
          <div>Test</div>
        </AuthProvider>,
      );
    });

    expect(ssr.createBrowserClient).toHaveBeenCalledWith(
      "",
      "",
      expect.objectContaining({
        global: expect.objectContaining({
          fetch: expect.any(Function),
        }),
      }),
    );

    vi.unstubAllEnvs();
  });

  it("should handle empty user response (no error, no user)", async () => {
    mockSupabase.auth.getUser.mockResolvedValue({
      data: { user: undefined } as unknown as { user: User },
      error: null,
    } as unknown as { data: { user: User | null }; error: null });

    await act(async () => {
      render(
        <AuthProvider>
          <TestComponent />
        </AuthProvider>,
      );
    });

    await waitFor(() => {
      expect(screen.getByTestId("user").textContent).toBe("No User");
    });
  });

  it("should handle throw in initUser catch block", async () => {
    const consoleSpy = vi.spyOn(console, "error").mockImplementation(() => {});
    mockSupabase.auth.getUser.mockImplementation(() => {
      throw new Error("Initialization Error");
    });

    await act(async () => {
      render(
        <AuthProvider>
          <TestComponent />
        </AuthProvider>,
      );
    });

    await waitFor(() => {
      expect(consoleSpy).toHaveBeenCalledWith(
        "Error fetching user:",
        expect.any(Error),
      );
    });

    consoleSpy.mockRestore();
  });

  it("should toggle auth modal", async () => {
    const ModalControls = () => {
      const { isAuthModalOpen, openAuthModal, closeAuthModal } = useAuth();
      return (
        <div>
          <div data-testid="modal-status">
            {isAuthModalOpen ? "Open" : "Closed"}
          </div>
          <button type="button" onClick={() => openAuthModal()}>
            Open Modal
          </button>
          <button type="button" onClick={closeAuthModal}>
            Close Modal
          </button>
        </div>
      );
    };

    await act(async () => {
      render(
        <AuthProvider>
          <ModalControls />
        </AuthProvider>,
      );
    });

    expect(screen.getByTestId("modal-status").textContent).toBe("Closed");

    await act(async () => {
      fireEvent.click(screen.getByText("Open Modal"));
    });
    expect(screen.getByTestId("modal-status").textContent).toBe("Open");

    await act(async () => {
      fireEvent.click(screen.getByText("Close Modal"));
    });
    expect(screen.getByTestId("modal-status").textContent).toBe("Closed");
  });

  it("should handle error during initialization when unmounted", async () => {
    const consoleSpy = vi.spyOn(console, "error").mockImplementation(() => {});
    let rejectGetUser: (reason?: unknown) => void = () => {};
    mockSupabase.auth.getUser.mockReturnValue(
      new Promise((_, reject) => {
        rejectGetUser = reject;
      }),
    );

    const { unmount } = render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>,
    );

    unmount();

    await act(async () => {
      rejectGetUser(new Error("Init failed"));
    });

    expect(consoleSpy).toHaveBeenCalledWith(
      "Error fetching user:",
      expect.any(Error),
    );
    consoleSpy.mockRestore();
  });

  it("should handle auth state change when unmounted", async () => {
    let authStateCallback:
      | ((
          event: string,
          session: { user: { id: string } } | null,
        ) => Promise<void>)
      | null = null;
    mockSupabase.auth.onAuthStateChange.mockImplementation(
      (
        cb: (
          event: string,
          session: { user: { id: string } } | null,
        ) => Promise<void>,
      ) => {
        authStateCallback = cb;
        return { data: { subscription: { unsubscribe: vi.fn() } } };
      },
    );

    const { unmount } = render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>,
    );
    unmount();

    await act(async () => {
      if (authStateCallback) {
        await authStateCallback("SIGNED_IN", { user: { id: "1" } });
      }
    });
  });

  it("should configure fetch with token and apikey sanitization", async () => {
    await act(async () => {
      render(
        <AuthProvider>
          <div>Test</div>
        </AuthProvider>,
      );
    });

    const config = vi.mocked(ssr.createBrowserClient).mock.calls[0]?.[2];
    if (!config?.global?.fetch) {
      throw new Error("config.global.fetch is undefined");
    }
    const customFetch = config.global.fetch;

    const mockGlobalFetch = vi.fn().mockResolvedValue({});
    global.fetch = mockGlobalFetch;

    const headers1 = new Headers({ Authorization: "Bearer invalid-token" });
    await customFetch("url", { headers: headers1 });
    expect(
      mockGlobalFetch.mock.calls[0]?.[1].headers.get("Authorization"),
    ).toBeNull();

    const headers2 = { Authorization: "Bearer a.b.c" };
    await customFetch("url", { headers: headers2 });
    expect(
      mockGlobalFetch.mock.calls[1]?.[1].headers.get("Authorization"),
    ).toBe("Bearer a.b.c");

    await customFetch("url", { headers: { "X-Test": "Value" } });
    expect(
      mockGlobalFetch.mock.calls[
        mockGlobalFetch.mock.calls.length - 1
      ]?.[1].headers.get("X-Test"),
    ).toBe("Value");

    const headers3 = { apikey: "invalid-key" };
    await customFetch("url", { headers: headers3 });
    expect(mockGlobalFetch.mock.calls[3]?.[1].headers.get("apikey")).toBeNull();

    const headers4 = { apikey: "a.b.c" };
    await customFetch("url", { headers: headers4 });
    expect(mockGlobalFetch.mock.calls[4]?.[1].headers.get("apikey")).toBe(
      "a.b.c",
    );

    const headers5 = { Authorization: "None" };
    await customFetch("url", { headers: headers5 });

    const headers6 = { Authorization: "Bearer " };
    await customFetch("url", { headers: headers6 });

    await customFetch("url");
    await customFetch("url", {});
  });

  it("should configure cookie methods correctly", async () => {
    await act(async () => {
      render(
        <AuthProvider>
          <div>Test</div>
        </AuthProvider>,
      );
    });

    const config = vi.mocked(ssr.createBrowserClient).mock.calls[0]?.[2];
    if (!config?.cookies) {
      throw new Error("config.cookies is undefined");
    }
    const cookies = config.cookies;

    Object.defineProperty(document, "cookie", {
      writable: true,
      value: "",
    });

    cookies.set?.("test-cookie", "test-value", {
      path: "/",
      maxAge: 3600,
      domain: "localhost",
      sameSite: "strict",
      secure: true,
    });
    expect(document.cookie).toContain("test-cookie=test-value");
    expect(document.cookie).toContain("path=/");
    expect(document.cookie).toContain("max-age=3600");
    expect(document.cookie).toContain("domain=localhost");
    expect(document.cookie).toContain("samesite=strict");
    expect(document.cookie).not.toContain("secure");

    cookies.set?.("no-sec-cookie", "val", { secure: false });
    expect(document.cookie).not.toContain("secure");

    const originalLocation = window.location;
    delete (window as any).location;
    window.location = { ...originalLocation, protocol: "https:" } as any;

    cookies.set?.("sec-cookie", "val", { secure: true });
    expect(document.cookie).toContain("secure");

    cookies.set?.("not-sec-cookie", "val", { secure: false });
    expect(document.cookie).not.toContain("secure");

    window.location = originalLocation as any;

    // biome-ignore lint/suspicious/noDocumentCookie: Test helper
    document.cookie = "other=123; test-cookie=test-value; third=456";
    expect(cookies.get?.("test-cookie")).toBe("test-value");
    expect(cookies.get?.("non-existent")).toBe("");

    cookies.remove?.("test-cookie", { path: "/", domain: "localhost" });
    expect(document.cookie).toContain("test-cookie=; max-age=0");
    expect(document.cookie).toContain("path=/");
    expect(document.cookie).toContain("domain=localhost");

    cookies.remove?.("test-cookie", {});
    expect(document.cookie).toBe("test-cookie=; max-age=0");
  });

  it("should return empty or do nothing if document is undefined", async () => {
    await act(async () => {
      render(
        <AuthProvider>
          <div>Test</div>
        </AuthProvider>,
      );
    });

    const config = vi.mocked(ssr.createBrowserClient).mock.calls[0]?.[2];
    const cookies = config?.cookies;
    if (!cookies) throw new Error("config.cookies is undefined");

    const originalDocument = global.document;
    // @ts-expect-error
    delete global.document;

    expect(cookies.get?.("any")).toBe("");
    cookies.set?.("any", "any", {});
    cookies.remove?.("any", {});

    global.document = originalDocument;
  });
});

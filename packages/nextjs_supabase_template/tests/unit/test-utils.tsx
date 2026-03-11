import type { User } from "@supabase/supabase-js";
import { vi } from "vitest";

// --- Auth Mocks ---
export const mockUseAuth = (overrides: Partial<any> = {}) => {
  const defaultAuth = {
    user: { id: "test-user-id" } as User,
    profile: { username: "testuser" },
    loading: false,
    signOut: vi.fn(),
    openAuthModal: vi.fn(),
    closeAuthModal: vi.fn(),
    authModalRedirectPath: null,
    isAuthModalOpen: false,
    supabase: {} as any,
  };
  return { ...defaultAuth, ...overrides };
};

export const mockNextNavigation = () => {
  const push = vi.fn();
  const replace = vi.fn();
  const back = vi.fn();
  const forward = vi.fn();
  const refresh = vi.fn();
  const prefetch = vi.fn();

  return {
    useRouter: vi.fn(() => ({
      push,
      replace,
      back,
      forward,
      refresh,
      prefetch,
    })),
    usePathname: vi.fn(() => "/"),
    useSearchParams: vi.fn(() => ({
      get: vi.fn(),
      getAll: vi.fn(),
      has: vi.fn(),
      forEach: vi.fn(),
      entries: vi.fn(),
      keys: vi.fn(),
      values: vi.fn(),
      toString: vi.fn(),
    })),
    mocks: { push, replace, back, forward, refresh, prefetch },
  };
};

export const mockToast = () => {
  const toastSuccess = vi.fn();
  const toastError = vi.fn();
  const toast = {
    success: toastSuccess,
    error: toastError,
  };
  return { toast, mocks: { toastSuccess, toastError } };
};

export const suppressNavigationWarnings = () => {
  const originalConsoleError = console.error;

  const setup = () => {
    vi.spyOn(console, "error").mockImplementation((msg, ...args) => {
      if (
        typeof msg === "string" &&
        msg.includes("Not implemented: navigation")
      ) {
        return;
      }
      if (msg?.toString().includes("Not implemented: navigation")) {
        return;
      }
      originalConsoleError(msg, ...args);
    });
  };

  const cleanup = () => {
    vi.restoreAllMocks();
  };

  return { setup, cleanup };
};

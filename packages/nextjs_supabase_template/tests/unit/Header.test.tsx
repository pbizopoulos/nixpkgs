import {
  act,
  cleanup,
  fireEvent,
  render,
  screen,
} from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import type { useAuth } from "../../components/AuthProvider";
import Header from "../../components/Header";
import { suppressNavigationWarnings } from "./test-utils";

const mocks = vi.hoisted(() => ({
  push: vi.fn(),
}));

vi.mock("next/navigation", () => ({
  useRouter: () => ({
    push: mocks.push,
  }),
  usePathname: () => "/",
}));

const mockAccessUser = vi.fn();
const mockSignOut = vi.fn();
const mockOpenAuthModal = vi.fn();

vi.mock("../../components/AuthProvider", () => ({
  useAuth: () => mockAccessUser(),
}));

vi.mock("../../components/UserAvatar", () => ({
  default: ({ username }: { username: string }) => (
    <div data-testid="user-avatar">{username}</div>
  ),
}));

describe("Header Component", () => {
  const { setup: setupConsole, cleanup: cleanupConsole } =
    suppressNavigationWarnings();

  beforeEach(() => {
    setupConsole();

    mockAccessUser.mockReturnValue({
      user: null,
      profile: null,
      signOut: mockSignOut,
      openAuthModal: mockOpenAuthModal,
      closeAuthModal: vi.fn(),
      authModalRedirectPath: null,
      loading: false,
    } as unknown as ReturnType<typeof useAuth>);
  });

  afterEach(() => {
    cleanup();
    cleanupConsole();
    vi.clearAllMocks();
    vi.restoreAllMocks();
  });

  it("shows sign in button when not logged in", () => {
    render(<Header />);
    expect(screen.getByRole("button", { name: /sign in/i })).toBeDefined();
  });

  it("should call handleClickOutside when not logged in", async () => {
    render(<Header />);
    await act(async () => {
      fireEvent.mouseDown(document.body);
    });
  });

  it("opens auth modal when sign in clicked", async () => {
    render(<Header />);
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /sign in/i }));
    });
    expect(mockOpenAuthModal).toHaveBeenCalledWith();
  });

  describe("Authenticated", () => {
    beforeEach(() => {
      mockAccessUser.mockReturnValue({
        user: { id: "123" },
        profile: { username: "testuser" },
        signOut: mockSignOut,
        openAuthModal: mockOpenAuthModal,
        loading: false,
      } as unknown as ReturnType<typeof useAuth>);
    });

    it("shows user avatar even when profile is missing", () => {
      mockAccessUser.mockReturnValue({
        user: { id: "123" },
        profile: null,
        signOut: mockSignOut,
        openAuthModal: mockOpenAuthModal,
        loading: false,
      } as unknown as ReturnType<typeof useAuth>);
      render(<Header />);
      expect(screen.getByTestId("user-avatar")).toBeDefined();
    });

    it("shows user avatar when logged in", () => {
      render(<Header />);
      expect(screen.getByTestId("user-avatar")).toBeDefined();
      expect(screen.getByText("testuser")).toBeDefined();
    });

    it("toggles dropdown when clicked", async () => {
      render(<Header />);
      const button = screen.getByRole("button", { name: /open user menu/i });
      await act(async () => {
        fireEvent.click(button);
      });
      expect(screen.getByRole("menu")).toBeDefined();
      expect(screen.getByRole("menuitem", { name: /sign out/i })).toBeDefined();

      await act(async () => {
        fireEvent.click(button);
      });
      expect(screen.queryByRole("menu")).toBeNull();
    });

    it("closes dropdown when clicking outside", async () => {
      render(<Header />);
      const button = screen.getByRole("button", { name: /open user menu/i });
      await act(async () => {
        fireEvent.click(button);
      });
      expect(screen.getByRole("menu")).toBeDefined();

      await act(async () => {
        fireEvent.mouseDown(document.body);
      });
      expect(screen.queryByRole("menu")).toBeNull();
    });

    it("calls signOut and redirects when sign out clicked", async () => {
      render(<Header />);
      await act(async () => {
        fireEvent.click(
          screen.getByRole("button", { name: /open user menu/i }),
        );
      });
      await act(async () => {
        fireEvent.click(screen.getByRole("menuitem", { name: /sign out/i }));
      });
      expect(mockSignOut).toHaveBeenCalled();
      await vi.waitFor(() => expect(mocks.push).toHaveBeenCalledWith("/"));
    });
  });

  describe("Accessibility", () => {
    it("should render navigation landmark (banner)", () => {
      render(<Header />);
      const banner = screen.getByRole("banner");
      expect(banner).toBeDefined();
    });

    it("should have accessible logo link", () => {
      render(<Header />);
      const homeLink = screen.getByRole("link", { name: /home/i });
      expect(homeLink).toBeDefined();
    });
  });
});

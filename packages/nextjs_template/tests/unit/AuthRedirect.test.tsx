import { cleanup, fireEvent, render, screen } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import AuthModal from "../../components/AuthModal";
import * as authProvider from "../../components/AuthProvider";

const mockPush = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({
    push: mockPush,
  }),
  usePathname: () => "/",
}));

vi.mock("../../components/AuthProvider", () => ({
  useAuth: vi.fn(),
}));

vi.mock("../../components/AuthForm", () => ({
  default: ({ onSuccess }: { onSuccess?: () => void }) => (
    <div data-testid="auth-form-mock">
      <button type="button" onClick={onSuccess}>
        Success
      </button>
    </div>
  ),
}));

describe("AuthRedirect Logic", () => {
  const closeAuthModal = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
    cleanup();
  });

  afterEach(() => {
    cleanup();
  });

  it("should redirect to authModalRedirectPath on success", () => {
    vi.mocked(authProvider.useAuth).mockReturnValue({
      isAuthModalOpen: true,
      authModalRedirectPath: "/original-target",
      closeAuthModal,
      user: { id: "1" } as any,
    } as any);

    render(<AuthModal />);

    fireEvent.click(screen.getByText("Success"));

    expect(closeAuthModal).toHaveBeenCalled();
    expect(mockPush).toHaveBeenCalledWith("/original-target");
  });

  it("should NOT redirect if authModalRedirectPath is null", () => {
    vi.mocked(authProvider.useAuth).mockReturnValue({
      isAuthModalOpen: true,
      authModalRedirectPath: null,
      closeAuthModal,
      user: { id: "1" } as any,
    } as any);

    render(<AuthModal />);

    fireEvent.click(screen.getByText("Success"));

    expect(closeAuthModal).toHaveBeenCalled();
    expect(mockPush).not.toHaveBeenCalled();
  });
});

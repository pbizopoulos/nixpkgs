import {
  cleanup,
  fireEvent,
  render,
  screen,
  within,
} from "@testing-library/react";
import * as navigation from "next/navigation";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import AuthModal from "../../components/AuthModal";
import * as authProvider from "../../components/AuthProvider";

vi.mock("next/navigation", () => ({
  useRouter: vi.fn(() => ({
    push: vi.fn(),
  })),
  usePathname: vi.fn(() => "/"),
}));

vi.mock("../../components/AuthProvider", () => ({
  useAuth: vi.fn(),
}));

vi.mock("../../components/AuthForm", () => ({
  default: ({ onSuccess }: { onSuccess?: () => void }) => (
    <div data-testid="auth-form-mock">
      <button type="button" onClick={onSuccess}>
        Close Form Mock
      </button>
    </div>
  ),
}));

describe("AuthModal", () => {
  const closeAuthModal = vi.fn();
  const mockPush = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
    cleanup();
    vi.mocked(authProvider.useAuth).mockReturnValue({
      isAuthModalOpen: true,
      closeAuthModal,
      user: null,
      authModalRedirectPath: null,
    } as unknown as ReturnType<typeof authProvider.useAuth>);

    vi.mocked(navigation.useRouter).mockReturnValue({
      push: mockPush,
    } as any);
    vi.mocked(navigation.usePathname).mockReturnValue("/");
  });

  afterEach(() => {
    cleanup();
  });

  it("should render nothing if not open", () => {
    vi.mocked(authProvider.useAuth).mockReturnValue({
      isAuthModalOpen: false,
      closeAuthModal,
    } as unknown as ReturnType<typeof authProvider.useAuth>);
    render(<AuthModal />);
    expect(screen.queryByTestId("auth-form-mock")).toBeNull();
  });

  it("should render form if open", () => {
    render(<AuthModal />);
    expect(screen.getByTestId("auth-form-mock")).toBeDefined();
  });

  it("should close on close button click", () => {
    render(<AuthModal />);
    fireEvent.click(screen.getByLabelText("Close modal"));
    expect(closeAuthModal).toHaveBeenCalled();
  });

  it("should redirect on close if on protected route without user", () => {
    vi.mocked(navigation.usePathname).mockReturnValue("/profile/edit");
    render(<AuthModal />);
    fireEvent.click(screen.getByLabelText("Close modal"));
    expect(mockPush).toHaveBeenCalledWith("/");
  });

  it("should redirect on form success if redirect path is set", () => {
    vi.mocked(authProvider.useAuth).mockReturnValue({
      isAuthModalOpen: true,
      closeAuthModal,
      authModalRedirectPath: "/dashboard",
    } as unknown as ReturnType<typeof authProvider.useAuth>);
    render(<AuthModal />);
    const form = screen.getByTestId("auth-form-mock");
    fireEvent.click(within(form).getByText("Close Form Mock"));
    expect(mockPush).toHaveBeenCalledWith("/dashboard");
  });

  it("should close on form success", () => {
    render(<AuthModal />);
    const form = screen.getByTestId("auth-form-mock");
    fireEvent.click(within(form).getByText("Close Form Mock"));
    expect(closeAuthModal).toHaveBeenCalled();
  });

  it("should close on escape key", () => {
    render(<AuthModal />);
    fireEvent.keyDown(document, { key: "Escape" });
    expect(closeAuthModal).toHaveBeenCalled();
  });

  it("should not close on non-Escape key", () => {
    render(<AuthModal />);
    fireEvent.keyDown(document, { key: "Enter" });
    expect(closeAuthModal).not.toHaveBeenCalled();
  });

  it("should not close when clicking inside the modal content", () => {
    render(<AuthModal />);
    const modalContent = screen.getByTestId("auth-form-mock").parentElement!;
    fireEvent.mouseDown(modalContent);
    expect(closeAuthModal).not.toHaveBeenCalled();
  });

  it("should close on backdrop click", () => {
    render(<AuthModal />);
    const backdrop =
      screen.getByLabelText("Close modal").parentElement?.parentElement;
    if (backdrop) {
      fireEvent.mouseDown(backdrop);
      expect(closeAuthModal).toHaveBeenCalled();
    }
  });
});

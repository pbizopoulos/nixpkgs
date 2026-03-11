import type { SupabaseClient } from "@supabase/supabase-js";
import {
  cleanup,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import * as navigation from "next/navigation";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import AuthForm from "../../components/AuthForm";
import * as authProvider from "../../components/AuthProvider";

vi.mock("next/navigation", () => ({
  useRouter: vi.fn(),
  useSearchParams: vi.fn(),
}));

vi.mock("../../components/AuthProvider", () => ({
  useAuth: vi.fn(),
}));

describe("AuthForm", () => {
  const mockPush = vi.fn();
  const mockSearchParams = { get: vi.fn().mockReturnValue(null) };
  const mockSupabase = {
    auth: {
      signUp: vi.fn(),
      signInWithPassword: vi.fn(),
    },
  };

  beforeEach(() => {
    cleanup();
    vi.clearAllMocks();
    vi.mocked(navigation.useRouter).mockReturnValue({
      push: mockPush,
    } as unknown as ReturnType<typeof navigation.useRouter>);
    vi.mocked(navigation.useSearchParams).mockReturnValue(
      mockSearchParams as any,
    );
    vi.mocked(authProvider.useAuth).mockReturnValue({
      supabase: mockSupabase as unknown as SupabaseClient,
    } as unknown as ReturnType<typeof authProvider.useAuth>);
  });

  afterEach(() => {
    cleanup();
  });

  it("should render sign in form by default", async () => {
    render(<AuthForm />);
    await waitFor(() => {
      const headings = screen.getAllByRole("heading", { name: "Sign In" });
      expect(headings[0]).toBeDefined();
    });

    const emails = screen.getAllByRole("textbox", { name: /email/i });
    expect(emails.length).toBe(1);

    expect(screen.getByLabelText(/^password/i)).toBeDefined();
    expect(screen.getByRole("button", { name: "Sign In" })).toBeDefined();
  });

  it("should switch to sign up mode", async () => {
    render(<AuthForm />);
    await waitFor(() => screen.getAllByRole("heading", { name: "Sign In" }));
    fireEvent.click(
      screen.getByRole("button", { name: /Don't have an account?/ }),
    );
    await waitFor(() => {
      const headings = screen.getAllByRole("heading", { name: "Sign Up" });
      expect(headings[0]).toBeDefined();
    });

    const usernames = screen.getAllByRole("textbox", { name: /username/i });
    expect(usernames.length).toBe(1);

    expect(
      screen.getByRole("button", { name: "Create Account" }),
    ).toBeDefined();

    fireEvent.click(
      screen.getByRole("button", { name: /Already have an account?/ }),
    );
    await waitFor(() => {
      const headings = screen.getAllByRole("heading", { name: "Sign In" });
      expect(headings[0]).toBeDefined();
    });
  });

  it("should validate username in sign up mode", async () => {
    render(<AuthForm />);
    await waitFor(() => screen.getAllByRole("heading", { name: "Sign In" }));
    fireEvent.click(
      screen.getByRole("button", { name: /Don't have an account?/ }),
    );

    await waitFor(() => {
      expect(screen.getByRole("textbox", { name: /username/i })).toBeDefined();
    });

    const usernameInput = screen.getByRole("textbox", { name: /username/i });
    fireEvent.change(usernameInput, { target: { value: "ab" } });

    const form = usernameInput.closest("form");
    expect(form).toBeDefined();
    if (form) fireEvent.submit(form);

    await waitFor(() => {
      expect(
        screen.getByText(/Invalid username: must be a valid slug/),
      ).toBeDefined();
    });
    expect(mockSupabase.auth.signUp).not.toHaveBeenCalled();
  });

  it("should handle successful sign up", async () => {
    vi.mocked(mockSupabase.auth.signUp).mockResolvedValue({
      data: { user: { id: "1" }, session: null },
      error: null,
    });

    render(<AuthForm />);
    await waitFor(() => screen.getAllByRole("heading", { name: "Sign In" }));
    fireEvent.click(
      screen.getByRole("button", { name: /Don't have an account?/ }),
    );

    fireEvent.change(screen.getByRole("textbox", { name: /username/i }), {
      target: { value: "test-user" },
    });
    fireEvent.change(screen.getByRole("textbox", { name: /email/i }), {
      target: { value: "test@example.com" },
    });
    fireEvent.change(screen.getByLabelText(/^password/i), {
      target: { value: "password123" },
    });

    const form = screen
      .getByRole("textbox", { name: /username/i })
      .closest("form");
    if (form) fireEvent.submit(form);

    await waitFor(() => {
      expect(
        screen.getByText(/Please check your email to verify/),
      ).toBeDefined();
    });
  });

  it("should handle successful sign in", async () => {
    vi.mocked(mockSupabase.auth.signInWithPassword).mockResolvedValue({
      data: { session: {} },
      error: null,
    });

    render(<AuthForm />);
    await waitFor(() => screen.getAllByRole("heading", { name: "Sign In" }));

    fireEvent.change(screen.getByRole("textbox", { name: /email/i }), {
      target: { value: "test@example.com" },
    });
    fireEvent.change(screen.getByLabelText(/^password/i), {
      target: { value: "password123" },
    });

    const form = screen
      .getByRole("textbox", { name: /email/i })
      .closest("form");
    if (form) fireEvent.submit(form);

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/");
    });
  });

  it("should handle sign in error", async () => {
    vi.mocked(mockSupabase.auth.signInWithPassword).mockResolvedValue({
      data: { session: null },
      error: { message: "Invalid login credentials" },
    });

    render(<AuthForm />);
    await waitFor(() => screen.getAllByRole("heading", { name: "Sign In" }));

    fireEvent.change(screen.getByRole("textbox", { name: /email/i }), {
      target: { value: "test@example.com" },
    });
    fireEvent.change(screen.getByLabelText(/^password/i), {
      target: { value: "password123" },
    });

    const form = screen
      .getByRole("textbox", { name: /email/i })
      .closest("form");
    if (form) fireEvent.submit(form);

    await waitFor(() => {
      expect(screen.getByText("Invalid login credentials")).toBeDefined();
    });
  });
  it("should handle signup error", async () => {
    vi.mocked(mockSupabase.auth.signUp).mockResolvedValue({
      data: { user: null, session: null },
      error: { message: "User already exists" },
    });

    render(<AuthForm />);
    fireEvent.click(
      screen.getByRole("button", { name: /Don't have an account?/ }),
    );

    fireEvent.change(screen.getByRole("textbox", { name: /username/i }), {
      target: { value: "test-user" },
    });
    fireEvent.change(screen.getByRole("textbox", { name: /email/i }), {
      target: { value: "test@example.com" },
    });
    fireEvent.change(screen.getByLabelText(/^password/i), {
      target: { value: "password123" },
    });

    const form = screen
      .getByRole("textbox", { name: /username/i })
      .closest("form");
    if (form) fireEvent.submit(form);

    await waitFor(() => {
      expect(screen.getByText("User already exists")).toBeDefined();
    });
  });

  it("should call onSuccess on signup success", async () => {
    vi.mocked(mockSupabase.auth.signUp).mockResolvedValue({
      data: { user: { id: "1" }, session: { user: { id: "1" } } },
      error: null,
    });
    const mockOnSuccess = vi.fn();

    render(<AuthForm onSuccess={mockOnSuccess} />);
    fireEvent.click(
      screen.getByRole("button", { name: /Don't have an account?/ }),
    );

    fireEvent.change(screen.getByRole("textbox", { name: /username/i }), {
      target: { value: "test-user" },
    });
    fireEvent.change(screen.getByRole("textbox", { name: /email/i }), {
      target: { value: "test@example.com" },
    });
    fireEvent.change(screen.getByLabelText(/^password/i), {
      target: { value: "password123" },
    });

    const form = screen
      .getByRole("textbox", { name: /username/i })
      .closest("form");
    if (form) fireEvent.submit(form);

    await waitFor(() => {
      expect(mockOnSuccess).toHaveBeenCalled();
    });
  });

  it("should redirect on signup success if no onSuccess", async () => {
    vi.mocked(mockSupabase.auth.signUp).mockResolvedValue({
      data: { user: { id: "1" }, session: { user: { id: "1" } } },
      error: null,
    });

    render(<AuthForm />);
    fireEvent.click(
      screen.getByRole("button", { name: /Don't have an account?/ }),
    );

    fireEvent.change(screen.getByRole("textbox", { name: /username/i }), {
      target: { value: "test-user" },
    });
    fireEvent.change(screen.getByRole("textbox", { name: /email/i }), {
      target: { value: "test@example.com" },
    });
    fireEvent.change(screen.getByLabelText(/^password/i), {
      target: { value: "password123" },
    });

    const form = screen
      .getByRole("textbox", { name: /username/i })
      .closest("form");
    if (form) fireEvent.submit(form);

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/");
    });
  });

  it("should redirect to custom URL on sign in success", async () => {
    vi.mocked(mockSupabase.auth.signInWithPassword).mockResolvedValue({
      data: { session: {} },
      error: null,
    });
    vi.mocked(mockSearchParams.get).mockReturnValue("/custom-redirect");

    render(<AuthForm />);

    fireEvent.change(screen.getByRole("textbox", { name: /email/i }), {
      target: { value: "test@example.com" },
    });
    fireEvent.change(screen.getByLabelText(/^password/i), {
      target: { value: "password123" },
    });

    const form = screen
      .getByRole("textbox", { name: /email/i })
      .closest("form");
    if (form) fireEvent.submit(form);

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/custom-redirect");
    });
  });

  it("should call onSuccess on sign in success", async () => {
    vi.mocked(mockSupabase.auth.signInWithPassword).mockResolvedValue({
      data: { session: {} },
      error: null,
    });
    const mockOnSuccess = vi.fn();

    render(<AuthForm onSuccess={mockOnSuccess} />);

    fireEvent.change(screen.getByRole("textbox", { name: /email/i }), {
      target: { value: "test@example.com" },
    });
    fireEvent.change(screen.getByLabelText(/^password/i), {
      target: { value: "password123" },
    });

    const form = screen
      .getByRole("textbox", { name: /email/i })
      .closest("form");
    if (form) fireEvent.submit(form);

    await waitFor(() => {
      expect(mockOnSuccess).toHaveBeenCalled();
    });
  });
});

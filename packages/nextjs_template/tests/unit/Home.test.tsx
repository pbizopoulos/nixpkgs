import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import Page from "../../app/page";

vi.mock("../../lib/supabase", () => ({
  createClient: vi.fn(() =>
    Promise.resolve({
      auth: {
        getUser: vi.fn(() => Promise.resolve({ data: { user: null } })),
      },
    }),
  ),
}));

describe("Home Page", () => {
  it("renders welcome message when not logged in", async () => {
    const page = await Page();
    render(page);
    expect(
      screen.getByText("Welcome to the Minimal Application"),
    ).toBeDefined();
    expect(
      screen.getByText("Please sign in to access your dashboard."),
    ).toBeDefined();
  });

  it("renders welcome message when logged in", async () => {
    const { createClient } = await import("../../lib/supabase");
    vi.mocked(createClient).mockResolvedValue({
      auth: {
        getUser: vi.fn(() =>
          Promise.resolve({ data: { user: { email: "test@example.com" } } }),
        ),
      },
    } as any);

    const page = await Page();
    render(page);
    expect(
      screen.getByText("You are logged in as test@example.com"),
    ).toBeDefined();
  });
});

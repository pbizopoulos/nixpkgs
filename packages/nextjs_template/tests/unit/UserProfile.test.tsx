import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import UserProfilePage from "../../app/[username]/page";

vi.mock("../../lib/supabase", () => ({
  createClient: vi.fn(() =>
    Promise.resolve({
      from: vi.fn(() => ({
        select: vi.fn(() => ({
          eq: vi.fn(() => ({
            maybeSingle: vi.fn(() => Promise.resolve({ data: null })),
          })),
        })),
      })),
    }),
  ),
}));

vi.mock("next/navigation", () => ({
  notFound: vi.fn(),
}));

describe("User Profile Page", () => {
  it("calls notFound if profile doesn't exist", async () => {
    const { notFound } = await import("next/navigation");
    await UserProfilePage({ params: Promise.resolve({ username: "unknown" }) });
    expect(notFound).toHaveBeenCalled();
  });

  it("renders user profile if it exists", async () => {
    const { createClient } = await import("../../lib/supabase");
    const mockProfile = { username: "testuser", full_name: "Test User" };

    vi.mocked(createClient).mockResolvedValue({
      from: vi.fn(() => ({
        select: vi.fn(() => ({
          eq: vi.fn(() => ({
            maybeSingle: vi.fn(() => Promise.resolve({ data: mockProfile })),
          })),
        })),
      })),
    } as any);

    const page = await UserProfilePage({
      params: Promise.resolve({ username: "testuser" }),
    });
    render(page);

    expect(screen.getByText("testuser")).toBeDefined();
    expect(screen.getByText("Test User")).toBeDefined();
  });
});

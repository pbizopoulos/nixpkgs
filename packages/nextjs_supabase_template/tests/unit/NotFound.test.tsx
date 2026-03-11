import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import NotFound from "../../app/not-found";

describe("NotFound", () => {
  it("renders not found page", () => {
    render(<NotFound />);
    expect(screen.getByText("Page Not Found")).toBeDefined();
    expect(screen.getByRole("link", { name: "Return Home" })).toBeDefined();
  });
});

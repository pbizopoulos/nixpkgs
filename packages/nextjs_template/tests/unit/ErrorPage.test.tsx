import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import ErrorPage from "../../app/error";

describe("ErrorPage", () => {
  it("renders correctly and calls reset on button click", () => {
    const error = new Error("Test error") as Error & { digest?: string };
    const reset = vi.fn();
    const consoleSpy = vi.spyOn(console, "error").mockImplementation(() => {});

    render(<ErrorPage error={error} reset={reset} />);

    expect(screen.getByText("Something went wrong!")).toBeDefined();
    expect(screen.getByText("Try again")).toBeDefined();

    fireEvent.click(screen.getByText("Try again"));
    expect(reset).toHaveBeenCalled();
    expect(consoleSpy).toHaveBeenCalledWith(error);
    consoleSpy.mockRestore();
  });
});

import { render } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import Loading from "../../app/loading";

describe("Loading", () => {
  it("renders loading spinner", () => {
    const { container } = render(<Loading />);
    expect(container.querySelector(".animate-spin")).toBeDefined();
  });
});

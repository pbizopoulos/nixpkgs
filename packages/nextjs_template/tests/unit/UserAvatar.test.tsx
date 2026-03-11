import { cleanup, render, screen } from "@testing-library/react";
import React from "react";
import { afterEach, describe, expect, it } from "vitest";
import UserAvatar from "../../components/UserAvatar";

afterEach(() => {
  cleanup();
});

describe("UserAvatar", () => {
  describe("with username", () => {
    it("should render initials from username", () => {
      render(React.createElement(UserAvatar, { username: "testuser" }));
      const initials = screen.getByText("TE");
      expect(initials).toBeDefined();
    });

    it("should render uppercase initials", () => {
      render(React.createElement(UserAvatar, { username: "john" }));
      const initials = screen.getByText("JO");
      expect(initials).toBeDefined();
    });

    it("should handle single character username", () => {
      render(React.createElement(UserAvatar, { username: "x" }));
      const initials = screen.getByText("X");
      expect(initials).toBeDefined();
    });

    it("should generate deterministic avatar color for same username", () => {
      const { container: container1 } = render(
        React.createElement(UserAvatar, { username: "alice" }),
      );
      const bg1 = container1.querySelector("div")?.style.backgroundColor;
      cleanup();
      const { container: container2 } = render(
        React.createElement(UserAvatar, { username: "alice" }),
      );
      const bg2 = container2.querySelector("div")?.style.backgroundColor;
      expect(bg1).toBe(bg2);
    });

    it("should generate different colors for different usernames", () => {
      const { container: container1 } = render(
        React.createElement(UserAvatar, { username: "alice" }),
      );
      const bg1 = container1.querySelector("div")?.style.backgroundColor;
      cleanup();

      const { container: container2 } = render(
        React.createElement(UserAvatar, { username: "bob" }),
      );
      const bg2 = container2.querySelector("div")?.style.backgroundColor;

      expect(bg1).not.toBe(bg2);
    });
  });

  describe("without username", () => {
    it("should render user icon when username is null", () => {
      const { container } = render(
        React.createElement(UserAvatar, { username: null }),
      );
      const icon = container.querySelector("svg");
      expect(icon).toBeDefined();
    });

    it("should render user icon when username is undefined", () => {
      const { container } = render(React.createElement(UserAvatar, {}));
      const icon = container.querySelector("svg");
      expect(icon).toBeDefined();
    });
  });

  describe("size prop", () => {
    it("should apply default size of 32", () => {
      const { container } = render(
        React.createElement(UserAvatar, { username: "test" }),
      );
      const div = container.querySelector("div");
      expect(div?.style.width).toBe("32px");
      expect(div?.style.height).toBe("32px");
    });

    it("should apply custom size", () => {
      const { container } = render(
        React.createElement(UserAvatar, { username: "test", size: 48 }),
      );
      const div = container.querySelector("div");
      expect(div?.style.width).toBe("48px");
      expect(div?.style.height).toBe("48px");
    });
  });

  describe("className prop", () => {
    it("should apply additional className", () => {
      const { container } = render(
        React.createElement(UserAvatar, {
          username: "test",
          className: "custom-class",
        }),
      );
      const div = container.querySelector("div");
      expect(div?.classList.contains("custom-class")).toBe(true);
    });
  });
});

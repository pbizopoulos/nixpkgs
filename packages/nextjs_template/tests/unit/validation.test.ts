import { describe, expect, it } from "vitest";
import { isValidUsername } from "../../lib/validation";

describe("isValidUsername", () => {
  it("should return false for empty string", () => {
    expect(isValidUsername("")).toBe(false);
  });

  it("should return false for too short username", () => {
    expect(isValidUsername("ab")).toBe(false);
  });

  it("should return false for too long username", () => {
    expect(isValidUsername("a".repeat(40))).toBe(false);
  });

  it("should return true for valid username", () => {
    expect(isValidUsername("valid-username-123")).toBe(true);
  });

  it("should return false for invalid characters", () => {
    expect(isValidUsername("invalid_username")).toBe(false);
    expect(isValidUsername("invalid username")).toBe(false);
    expect(isValidUsername("InvalidUsername")).toBe(false);
  });
});

import { describe, expect, it } from "vitest";
import { isValidUsername, SLUG_MAX_LENGTH } from "./validation.js";
describe("isValidUsername", () => {
  it("accepts lowercase slugs", () => {
    expect(isValidUsername("starter-app")).toBe(true);
  });
  it("rejects empty or short usernames", () => {
    expect(isValidUsername("")).toBe(false);
    expect(isValidUsername("ab")).toBe(false);
  });
  it("rejects invalid characters", () => {
    expect(isValidUsername("Starter App")).toBe(false);
    expect(isValidUsername("hello_world")).toBe(false);
  });
  it("enforces the maximum length", () => {
    expect(isValidUsername("a".repeat(SLUG_MAX_LENGTH))).toBe(true);
    expect(isValidUsername("a".repeat(SLUG_MAX_LENGTH + 1))).toBe(false);
  });
});

import { test } from "@japa/runner";
test.group("Environment variables", () => {
  test("APP_URL is defined", async ({ assert }) => {
    const { default: env } = await import("../../start/env.js");
    assert.exists(env.get("APP_URL"));
  });
});

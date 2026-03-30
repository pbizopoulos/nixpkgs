import { test } from "@japa/runner";
import {
  createUsernameValidator,
  SLUG_MAX_LENGTH,
} from "../../app/validators/username.js";
test.group("Username validator", () => {
  test("accepts lowercase slugs", async ({ assert }) => {
    const data = { username: "starter-app" };
    const validated = await createUsernameValidator.validate(data);
    assert.equal(validated.username, "starter-app");
  });
  test("rejects empty or short usernames", async ({ assert }) => {
    const data = { username: "ab" };
    await assert.rejects(async () => {
      await createUsernameValidator.validate(data);
    });
  });
  test("rejects invalid characters", async ({ assert }) => {
    const data = { username: "hello_world" };
    await assert.rejects(async () => {
      await createUsernameValidator.validate(data);
    });
  });
  test("enforces the maximum length", async ({ assert }) => {
    const data = { username: "a".repeat(SLUG_MAX_LENGTH) };
    const validated = await createUsernameValidator.validate(data);
    assert.equal(validated.username, "a".repeat(SLUG_MAX_LENGTH));
    const tooLong = { username: "a".repeat(SLUG_MAX_LENGTH + 1) };
    await assert.rejects(async () => {
      await createUsernameValidator.validate(tooLong);
    });
  });
});

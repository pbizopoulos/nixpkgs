import { test } from "@japa/runner";
import {
  loginValidator,
  registerUserValidator,
} from "../../app/validators/auth.js";
test.group("Auth validators", () => {
  test("accepts a valid registration payload", async ({ assert }) => {
    const payload = await registerUserValidator.validate({
      email: "starter@example.com",
      password: "password123",
      passwordConfirmation: "password123",
      username: "starter-user",
    });
    assert.equal(payload.email, "starter@example.com");
    assert.equal(payload.username, "starter-user");
  });
  test("rejects malformed registration payloads", async ({ assert }) => {
    await assert.rejects(async () => {
      await registerUserValidator.validate({
        email: "not-an-email",
        password: "short",
        passwordConfirmation: "short",
        username: "no spaces allowed",
      });
    });
  });
  test("accepts email or username login payloads", async ({ assert }) => {
    const payload = await loginValidator.validate({
      login: "starter-user",
      password: "password123",
    });
    assert.equal(payload.login, "starter-user");
  });
  test("rejects short login passwords", async ({ assert }) => {
    await assert.rejects(async () => {
      await loginValidator.validate({
        login: "starter-user",
        password: "short",
      });
    });
  });
});

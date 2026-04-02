import { test } from "@japa/runner";
import { DateTime } from "luxon";
import HomeController from "../../app/controllers/home_controller.js";
import { serializeUser } from "../../app/transformers/user_transformer.js";
test.group("User transformer", () => {
  test("serializes the public user shape", async ({ assert }) => {
    const timestamp = DateTime.utc(2026, 3, 30, 12, 0, 0);
    const user = {
      id: 7,
      email: "starter@example.com",
      username: "starter-user",
      createdAt: timestamp,
      password: "hashed-secret",
      updatedAt: timestamp.plus({ minutes: 1 }),
    };
    const serialized = serializeUser(user as never);
    assert.deepEqual(serialized, {
      id: 7,
      email: "starter@example.com",
      username: "starter-user",
      createdAt: timestamp.toISO(),
    });
    assert.deepEqual(Object.keys(serialized).sort(), [
      "createdAt",
      "email",
      "id",
      "username",
    ]);
  });
  test("home controller exposes only the serialized user fields", async ({
    assert,
  }) => {
    const timestamp = DateTime.utc(2026, 3, 30, 12, 0, 0);
    const renderCalls: Array<{ view: string; payload: unknown }> = [];
    const controller = new HomeController();
    await controller.show({
      auth: {
        check: async () => true,
        user: {
          id: 11,
          email: "controller@example.com",
          username: "controller-user",
          createdAt: timestamp,
          password: "hashed-secret",
        },
      },
      view: {
        render(view: string, payload: unknown) {
          renderCalls.push({ view, payload });
          return payload;
        },
      },
    } as never);
    assert.lengthOf(renderCalls, 1);
    assert.deepEqual(renderCalls[0], {
      view: "home",
      payload: {
        isAuthenticated: true,
        user: {
          id: 11,
          email: "controller@example.com",
          username: "controller-user",
          createdAt: timestamp.toISO(),
        },
      },
    });
  });
});

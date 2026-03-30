import { test } from "@japa/runner";
import { DateTime } from "luxon";
import { serializeUser } from "../../app/transformers/user_transformer.js";
test.group("User transformer", () => {
  test("serializes the public user shape", async ({ assert }) => {
    const timestamp = DateTime.utc(2026, 3, 30, 12, 0, 0);
    const user = {
      id: 7,
      username: "starter-user",
      createdAt: timestamp,
    };
    assert.deepEqual(serializeUser(user as never), {
      id: 7,
      username: "starter-user",
      createdAt: timestamp.toISO(),
    });
  });
});

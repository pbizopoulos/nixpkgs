import { test } from "@japa/runner";
import HttpExceptionHandler from "../../app/exceptions/handler.js";
test.group("Http exception handler", () => {
  test("debug is true outside production", async ({ assert }) => {
    const handler = new HttpExceptionHandler() as any;
    assert.isTrue(handler.debug);
  });
});

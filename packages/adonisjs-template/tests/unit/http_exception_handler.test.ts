import app from "@adonisjs/core/services/app";
import { test } from "@japa/runner";
import HttpExceptionHandler from "../../app/exceptions/handler.js";
test.group("Http exception handler", () => {
  test("debug is true outside production", async ({ assert }) => {
    const handler = new HttpExceptionHandler() as any;
    assert.equal(handler.debug, !app.inProduction);
    assert.equal(handler.renderStatusPages, app.inProduction);
  });
  test("registers the conventional status page ranges", async ({ assert }) => {
    const handler = new HttpExceptionHandler() as any;
    assert.deepEqual(Object.keys(handler.statusPages).sort(), [
      "404",
      "500..599",
    ]);
  });
  test("renders the 404 and 500 status pages", async ({ assert }) => {
    const handler = new HttpExceptionHandler() as any;
    const notFoundPage = handler.statusPages["404"]();
    const serverErrorPage = handler.statusPages["500..599"]();
    assert.include(notFoundPage, "<title>Page Not Found</title>");
    assert.include(notFoundPage, "<h1>Page Not Found</h1>");
    assert.include(notFoundPage, '<a href="/">Return Home</a>');
    assert.include(serverErrorPage, "<title>Server Error</title>");
    assert.include(serverErrorPage, "<h1>Something went wrong!</h1>");
    assert.include(serverErrorPage, "An unexpected error has occurred.");
  });
});

import { expect, test } from "@playwright/test";

test.describe("404 Error Handling", () => {
  test("should handle non-existent user gracefully", async ({ page }) => {
    await page.goto("/totally-fake-user-that-does-not-exist-xyz123");

    const notFoundHeading = page.getByRole("heading", {
      name: "Page Not Found",
    });
    await expect(notFoundHeading.first()).toBeVisible();
  });
});

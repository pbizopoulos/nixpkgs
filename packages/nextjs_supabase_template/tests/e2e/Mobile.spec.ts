import { devices, expect, test } from "@playwright/test";

test.use(devices["iPhone 13"]);

test.describe("Mobile Viewport", () => {
  test("should display landing page on mobile", async ({ page }) => {
    await page.goto("/");
    await expect(
      page.getByText("Welcome to the Minimal Application"),
    ).toBeVisible();
  });
});

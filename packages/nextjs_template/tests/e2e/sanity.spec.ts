import { expect, test } from "@playwright/test";

test("sanity check", async ({ page }) => {
  console.log("Navigating to root...");
  await page.goto("/");
  console.log("Navigated. Checking content...");
  await expect(page.getByRole("button", { name: /Sign In/i })).toBeVisible({
    timeout: 5000,
  });
  console.log("Sign In button visible.");
});

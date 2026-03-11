import { expect, test } from "@playwright/test";
import { signUpAndLogin } from "./Helpers";

test.describe("Sign Out", () => {
  test("should sign out and return to anonymous state", async ({ page }) => {
    await signUpAndLogin(page);

    const userMenuButton = page.getByLabel("Open user menu");
    await expect(userMenuButton).toBeVisible();

    await userMenuButton.click();

    await page.getByRole("menuitem", { name: /Sign Out/i }).click();

    await expect(page.getByRole("button", { name: /Sign In/i })).toBeVisible({
      timeout: 15000,
    });

    await expect(page.getByLabel("Open user menu")).not.toBeVisible();
  });
});

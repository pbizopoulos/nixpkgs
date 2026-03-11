import { expect, type Page } from "@playwright/test";

export async function signUpAndLogin(page: Page) {
  const uniqueId =
    Date.now().toString(36) + Math.random().toString(36).substring(2, 7);
  const username = `u-${uniqueId}`;
  const email = `${username}@example.com`;
  const password = "password123";

  await page.goto("/");

  const signInButton = page.getByRole("button", { name: /Sign In/i });
  await expect(signInButton).toBeVisible({ timeout: 15000 });
  await signInButton.click();

  const signUpHeader = page.getByRole("heading", { name: "Sign Up" });
  if (!(await signUpHeader.isVisible())) {
    await page
      .locator('button[type="button"]')
      .filter({ hasText: /Don't have an account|Already have an account/ })
      .click();
    await expect(signUpHeader).toBeVisible({ timeout: 5000 });
  }

  await page.locator("input#name").fill(username);
  await page.locator("input#email").fill(email);
  await page.locator("input#password").fill(password);

  const submitBtn = page.getByTestId("auth-submit");
  await expect(submitBtn).toBeEnabled({ timeout: 5000 });
  await submitBtn.click();

  try {
    await expect(page.getByLabel("Open user menu")).toBeVisible({
      timeout: 10000,
    });
  } catch (error: any) {
    const authForm = page.getByTestId("auth-form");
    const errorText = await authForm
      .locator(".bg-red-50")
      .textContent()
      .catch(() => null);
    if (errorText) throw new Error(`Signup failed with message: ${errorText}`);

    const successText = await authForm
      .locator(".bg-green-50")
      .textContent()
      .catch(() => null);
    if (successText?.includes("check your email")) {
      throw new Error("Signup stopped: Email verification required.");
    }
    throw error;
  }
  return { username, email, password, uniqueId };
}

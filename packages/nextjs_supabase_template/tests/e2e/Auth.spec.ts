import { expect, test } from "@playwright/test";

import { signUpAndLogin } from "./Helpers";

test.describe("Authentication", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
  });

  test("should sign up and login", async ({ page }) => {
    const { username } = await signUpAndLogin(page);

    const userMenuButton = page.getByLabel("Open user menu");
    await userMenuButton.click();
    await expect(page.getByText(`Signed in as`)).toBeVisible();
    await expect(page.getByText(username)).toBeVisible();
  });

  test("should show error for invalid credentials", async ({ page }) => {
    await page.getByRole("button", { name: /Sign In/i }).click();
    await expect(page.locator("input#email")).toBeVisible();

    await page.locator("input#email").fill("nonexistent@example.com");
    await page.locator("input#password").fill("wrongpassword123");

    await page.getByTestId("auth-submit").click();

    await expect(page.getByText(/invalid/i)).toBeVisible({ timeout: 10000 });
  });

  test("should require email and password", async ({ page }) => {
    await page.getByRole("button", { name: /Sign In/i }).click();
    await expect(page.locator("input#email")).toBeVisible();

    const emailInput = page.locator("input#email");
    await expect(emailInput).toHaveAttribute("type", "email");

    const passwordInput = page.locator("input#password");
    await expect(passwordInput).toBeVisible();
  });

  test("should toggle between sign in and sign up", async ({ page }) => {
    await page.getByRole("button", { name: /Sign In/i }).click();
    await expect(
      page
        .getByTestId("auth-form")
        .getByRole("heading", { name: "Sign In", level: 1 }),
    ).toBeVisible();

    await page
      .getByRole("button", { name: /Don't have an account\? Sign Up/i })
      .click();

    await expect(
      page
        .getByTestId("auth-form")
        .getByRole("heading", { name: "Sign Up", level: 1 }),
    ).toBeVisible();
    await expect(page.locator("input#name")).toBeVisible();

    await page
      .getByRole("button", { name: /Already have an account\? Sign In/i })
      .click();

    await expect(
      page
        .getByTestId("auth-form")
        .getByRole("heading", { name: "Sign In", level: 1 }),
    ).toBeVisible();
  });

  test("should require username in signup form", async ({ page }) => {
    await page.getByRole("button", { name: /Sign In/i }).click();

    await page
      .getByRole("button", { name: /Don't have an account\? Sign Up/i })
      .click();
    await expect(
      page
        .getByTestId("auth-form")
        .getByRole("heading", { name: "Sign Up", level: 1 }),
    ).toBeVisible();

    const usernameInput = page.locator("input#name");
    await expect(usernameInput).toBeVisible();
  });

  test("should display email input with correct type", async ({ page }) => {
    await page.getByRole("button", { name: /Sign In/i }).click();

    const emailInput = page.locator("input#email");
    await expect(emailInput).toHaveAttribute("type", "email");
  });

  test("should display password input with correct type", async ({ page }) => {
    await page.getByRole("button", { name: /Sign In/i }).click();

    const passwordInput = page.locator("input#password");
    await expect(passwordInput).toHaveAttribute("type", "password");
  });
});

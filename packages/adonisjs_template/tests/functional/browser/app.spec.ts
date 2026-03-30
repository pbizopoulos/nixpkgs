import { devices, expect, test } from "@playwright/test";
const isProductionRuntime =
  process.env.E2E_MODE === "prod" || process.env.NODE_ENV === "production";
test("visitor sees the full starter landing page", async ({ page }) => {
  await page.goto("/");
  await expect(page.locator("body")).toContainText(
    /build the app, not the scaffold/i,
  );
  await expect(page.locator("body")).toContainText(
    /sessions, shield, auth, limiter, mail/i,
  );
  await expect(page.getByRole("link", { name: /register/i })).toBeVisible();
  await expect(page.getByRole("link", { name: /login/i })).toBeVisible();
  await expect(page.getByRole("link", { name: /^docs$/i })).toHaveAttribute(
    "href",
    "https://docs.adonisjs.com",
  );
});
test("registration, login, logout, and account deletion work", async ({
  page,
}) => {
  const unique = Date.now();
  const username = `starter-user-${unique}`;
  const email = `starter-${unique}@example.com`;
  await page.goto("/register");
  await page.getByLabel("Username").fill(username);
  await page.getByLabel("Email").fill(email);
  await page.getByLabel("Password", { exact: true }).fill("password123");
  await page.getByLabel("Confirm password").fill("password123");
  await page.getByRole("button", { name: /create account/i }).click();
  await expect(page).toHaveURL(/\/app$/);
  await expect(page.locator("body")).toContainText(username);
  await expect(page.locator("body")).toContainText(email);
  await page.getByRole("button", { name: /sign out/i }).click();
  await expect(page).toHaveURL(/\/$/);
  await page.goto("/login");
  await page.getByLabel("Email or username").fill(email);
  await page.getByLabel("Password").fill("password123");
  await page.getByRole("button", { name: /sign in/i }).click();
  await expect(page).toHaveURL(/\/app$/);
  await expect(page.locator("body")).toContainText(/welcome back/i);
  await page.getByRole("button", { name: /delete account/i }).click();
  await expect(page).toHaveURL(/\/$/);
  await expect(page.locator("body")).toContainText(/account has been deleted/i);
});
test("health check reports the postgres dependency as healthy", async ({
  request,
}) => {
  await expect
    .poll(async () => (await request.get("/health")).status(), {
      timeout: 10000,
    })
    .toBe(200);
  const response = await request.get("/health");
  const report = (await response.json()) as { isHealthy: boolean };
  expect(report.isHealthy).toBe(true);
});
test("guests are redirected to login for the dashboard", async ({ page }) => {
  await page.goto("/app");
  await expect(page).toHaveURL(/\/login$/);
});
test.describe("Error Handling", () => {
  test("shows the conventional not-found response for the current environment", async ({
    page,
  }) => {
    await page.goto("/totally-fake-route-that-does-not-exist-xyz123");
    if (isProductionRuntime) {
      await expect(page.locator("body")).toContainText("Page Not Found");
      await expect(page.locator("body")).not.toContainText("Exception");
      await expect(page.locator("body")).not.toContainText(
        "Cannot GET:/totally-fake-route-that-does-not-exist-xyz123",
      );
      return;
    }
    await expect(page.locator("body")).toContainText("Exception");
    await expect(page.locator("body")).toContainText(
      "Cannot GET:/totally-fake-route-that-does-not-exist-xyz123",
    );
  });
});
test.describe("Mobile Viewport", () => {
  test("renders the landing page on mobile", async ({ browser }) => {
    const context = await browser.newContext({ ...devices["Pixel 5"] });
    const page = await context.newPage();
    await page.goto("/");
    await expect(page.locator("body")).toContainText(
      /build the app, not the scaffold/i,
    );
    await expect(page.locator("body")).toContainText(/hypermedia starter/i);
    await context.close();
  });
});
test.describe("Performance Audits @audit", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
  });
  test("Page should load within performance budget", async ({ page }) => {
    const performanceTiming = await page.evaluate(async () => {
      const perf = performance as Performance & {
        getEntriesByType(entryType: string): PerformanceEntry[];
      };
      const getPaintMetric = (name: string) =>
        new Promise<number>((resolve) => {
          const entries = performance.getEntriesByName(name);
          if (entries.length > 0 && entries[0]) {
            resolve(entries[0].startTime);
            return;
          }
          const observer = new PerformanceObserver((list) => {
            const paintEntries = list.getEntriesByName(name);
            if (paintEntries.length > 0 && paintEntries[0]) {
              observer.disconnect();
              resolve(paintEntries[0].startTime);
            }
          });
          observer.observe({ type: "paint" as never, buffered: true });
          setTimeout(() => {
            observer.disconnect();
            resolve(0);
          }, 5000);
        });
      const navigationEntry = perf.getEntriesByType(
        "navigation",
      )[0] as unknown as {
        loadEventEnd: number;
      };
      return {
        loadEventEnd: navigationEntry.loadEventEnd,
        firstContentfulPaint: await getPaintMetric("first-contentful-paint"),
      };
    });
    expect(performanceTiming.loadEventEnd).toBeLessThan(2000);
    if (performanceTiming.firstContentfulPaint > 0) {
      expect(performanceTiming.firstContentfulPaint).toBeLessThan(1500);
    }
  });
});

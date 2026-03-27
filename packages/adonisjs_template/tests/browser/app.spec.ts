import { devices, expect, test } from "@playwright/test";
const isProductionRuntime =
  process.env.E2E_MODE === "prod" || process.env.NODE_ENV === "production";
test("visitor sees the starter landing page", async ({ page }) => {
  await page.goto("/");
  await expect(page.locator("body")).toContainText(
    /build the app, not the scaffold/i,
  );
  await expect(page.locator("body")).toContainText(
    /clean adonisjs starting point/i,
  );
  await expect(
    page.getByRole("link", { name: /read the docs/i }),
  ).toHaveAttribute("href", "https://docs.adonisjs.com");
  await expect(
    page.getByRole("link", { name: /deploy the app/i }),
  ).toHaveAttribute(
    "href",
    "https://docs.adonisjs.com/guides/concepts/deployment",
  );
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
test("user registration and deletion works", async ({ request }) => {
  const username = `starter-user-${Date.now()}`;
  const registerResponse = await request.post("/users/register", {
    data: { username },
  });
  expect(registerResponse.status()).toBe(201);
  await expect(registerResponse.json()).resolves.toMatchObject({
    user: { username },
  });
  const deleteResponse = await request.delete(`/users/${username}`);
  expect(deleteResponse.status()).toBe(200);
  await expect(deleteResponse.json()).resolves.toMatchObject({
    deleted: true,
    username,
  });
  const secondDeleteResponse = await request.delete(`/users/${username}`);
  expect(secondDeleteResponse.status()).toBe(404);
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
  test("should display landing page on mobile", async ({ browser }) => {
    const context = await browser.newContext({ ...devices["Pixel 5"] });
    const page = await context.newPage();
    await page.goto("/");
    await expect(page.locator("body")).toContainText(
      /build the app, not the scaffold/i,
    );
    await expect(
      page.getByRole("link", { name: /read the docs/i }),
    ).toHaveAttribute("href", "https://docs.adonisjs.com");
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
  test("Missing routes should return 404", async ({ page }) => {
    const response = await page.goto("/api/non-existent-route-that-should-404");
    expect(response?.status()).toBe(404);
  });
});

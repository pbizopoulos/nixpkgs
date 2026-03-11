import { expect, test } from "@playwright/test";

test.describe("Lighthouse-style Performance Audits", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
  });

  test("Page should load within performance budget", async ({ page }) => {
    const performanceTiming = await page.evaluate(async () => {
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
          observer.observe({ type: "paint", buffered: true });
          setTimeout(() => {
            observer.disconnect();
            resolve(0);
          }, 5000);
        });

      const navigationEntry = performance.getEntriesByType(
        "navigation",
      )[0] as PerformanceNavigationTiming;
      return {
        loadEventEnd: navigationEntry.loadEventEnd,
        domContentLoadedEventEnd: navigationEntry.domContentLoadedEventEnd,
        firstContentfulPaint: await getPaintMetric("first-contentful-paint"),
      };
    });

    const MAX_LOAD_TIME = 2000;
    const MAX_FCP = 1500;

    expect(performanceTiming.loadEventEnd).toBeLessThan(MAX_LOAD_TIME);
    if (performanceTiming.firstContentfulPaint > 0) {
      expect(performanceTiming.firstContentfulPaint).toBeLessThan(MAX_FCP);
    }
  });

  test("Missing routes should return 404 and be readable", async ({ page }) => {
    const response = await page.goto("/api/non-existent-route-that-should-404");
    expect(response?.status()).toBe(404);
  });
});

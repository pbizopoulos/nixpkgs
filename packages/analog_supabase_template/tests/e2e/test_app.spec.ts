import { test, expect } from '@playwright/test';

test('has hello world', async ({ page }) => {
  await page.goto('/');
  const body = await page.innerText('body');
  expect(body).toContain('Hello World!');
});

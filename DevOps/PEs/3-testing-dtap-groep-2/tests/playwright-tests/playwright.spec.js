import { test, expect } from '@playwright/test';

test.describe('Applicatie testen', () => {

  test('AppHasAddButton', async ({ page }) => {
    await page.goto('/');

    const addButton = page.locator('button', { hasText: 'add' });

    await expect(addButton).toBeVisible();
  });

  test('AppCanSubtract', async ({ page }) => {
    await page.goto('/');

    await page.fill('#number1', '7');
    await page.fill('#number2', '3');

    await page.click('#subtract');

    const result = page.locator('#result');
    await expect(result).toHaveText('The result is: 4');
  });

});
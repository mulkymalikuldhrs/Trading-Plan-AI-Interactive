from playwright.sync_api import Page, expect, sync_playwright
import time

def test_v11_1_0_ui(page: Page):
    page.goto("http://localhost:44289")
    # Wait for the app to load
    time.sleep(10)

    # Take screenshot of the dashboard/entry page
    page.screenshot(path="verification/v11_1_0_entry.png")

    # Try to navigate to Dashboard
    page.click("text=Dashboard")
    time.sleep(2)
    page.screenshot(path="verification/v11_1_0_dashboard.png")

if __name__ == "__main__":
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        try:
            test_v11_1_0_ui(page)
        finally:
            browser.close()

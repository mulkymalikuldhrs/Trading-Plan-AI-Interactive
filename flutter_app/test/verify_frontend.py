from playwright.sync_api import sync_playwright
import os

def run_cuj(page):
    print("Navigating to http://localhost:8080...")
    page.goto("http://localhost:8080")

    # Wait for Flutter app to initialize
    print("Waiting for app to load...")
    page.wait_for_timeout(10000)

    # Capture EntryPage
    print("Capturing EntryPage...")
    os.makedirs("verification/screenshots", exist_ok=True)
    page.screenshot(path="verification/screenshots/entry_page.png")

    # Try to click Intel tab
    # The screenshot shows "Intel" at the bottom.
    # We will try multiple strategies
    print("Attempting to click Intel tab...")

    locators = [
        page.get_by_label("Intel"),
        page.get_by_text("Intel"),
        page.locator("flt-semantics-placeholder:has-text('Intel')"),
        page.locator("text='Intel'")
    ]

    success = False
    for loc in locators:
        try:
            if loc.is_visible():
                loc.click()
                print(f"Successfully clicked using {loc}")
                success = True
                break
        except:
            continue

    if not success:
        print("Standard locators failed, trying coordinate click for Intel (item 4 of 5)...")
        # Assuming 1280x720. 5 items: centers at 128, 384, 640, 896, 1152.
        # Bottom nav height is usually ~60-80px.
        page.mouse.click(896, 680)
        success = True

    page.wait_for_timeout(5000)
    print("Capturing IntelTab...")
    page.screenshot(path="verification/screenshots/intel_tab.png")

    # Take final screenshot
    page.screenshot(path="verification/screenshots/verification.png")
    page.wait_for_timeout(1000)
    print("Verification CUJ complete.")

if __name__ == "__main__":
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        os.makedirs("verification/videos", exist_ok=True)
        context = browser.new_context(
            record_video_dir="verification/videos"
        )
        page = context.new_page()
        try:
            run_cuj(page)
        finally:
            context.close()
            browser.close()

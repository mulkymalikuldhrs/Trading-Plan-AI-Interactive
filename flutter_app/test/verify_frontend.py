import asyncio
from playwright.async_api import async_playwright

async def run():
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page()
        try:
            await page.goto("http://localhost:8080", timeout=60000)
            await asyncio.sleep(10) # Wait for Flutter to load

            # Check for title
            title = await page.title()
            print(f"Page title: {title}")

            # Take screenshot
            await page.screenshot(path="flutter_web_verification.png")
            print("Screenshot saved to flutter_web_verification.png")

        except Exception as e:
            print(f"An error occurred: {e}")
        finally:
            await browser.close()

if __name__ == "__main__":
    asyncio.run(run())

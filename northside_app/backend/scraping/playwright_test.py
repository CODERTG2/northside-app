# Memory-efficient scraping using Playwright for Raspberry Pi
import asyncio
import time
from bs4 import BeautifulSoup

async def scrape_with_playwright():
    """
    Use Playwright which is more memory efficient than Selenium
    """
    print("Trying Playwright approach...")
    
    try:
        from playwright.async_api import async_playwright
        
        async with async_playwright() as p:
            print("Launching browser...")
            
            # Use Chromium with minimal resources
            browser = await p.chromium.launch(
                headless=True,
                args=[
                    '--no-sandbox',
                    '--disable-dev-shm-usage',
                    '--disable-gpu',
                    '--disable-software-rasterizer',
                    '--disable-extensions',
                    '--disable-plugins',
                    '--disable-images',
                    '--disable-javascript',  # Start without JS
                    '--memory-pressure-off',
                    '--disable-background-timer-throttling',
                    '--disable-backgrounding-occluded-windows',
                    '--disable-renderer-backgrounding',
                    '--disable-features=TranslateUI,BlinkGenPropertyTrees',
                    '--window-size=800,600',
                    '--max_old_space_size=128',  # Very low memory limit
                    '--disable-web-security',
                ]
            )
            
            print("✓ Browser launched successfully!")
            
            page = await browser.new_page()
            
            # Set very low resource limits
            await page.set_viewport_size({"width": 800, "height": 600})
            
            print("Navigating to URL...")
            await page.goto("https://www.northsideprepathletics.com/schedule?year=2025-2026", 
                          wait_until="domcontentloaded", timeout=30000)
            
            print("✓ Page loaded!")
            
            # Get initial content
            content = await page.content()
            print(f"Initial page content length: {len(content)}")
            
            # Try to scroll and load more content
            print("Attempting to scroll...")
            
            previous_height = await page.evaluate("document.body.scrollHeight")
            scroll_attempts = 0
            max_scrolls = 10  # Limited scrolls for Pi
            
            while scroll_attempts < max_scrolls:
                await page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
                await page.wait_for_timeout(2000)  # Wait 2 seconds
                
                new_height = await page.evaluate("document.body.scrollHeight")
                print(f"Scroll {scroll_attempts + 1}: height {new_height}")
                
                if new_height == previous_height:
                    print("✓ Reached bottom of page")
                    break
                    
                previous_height = new_height
                scroll_attempts += 1
            
            # Get final content
            final_content = await page.content()
            print(f"Final page content length: {len(final_content)}")
            
            await browser.close()
            
            # Parse content
            soup = BeautifulSoup(final_content, 'html.parser')
            
            # Look for schedule data
            dates = soup.find_all('h3', class_='uppercase')
            print(f"Found {len(dates)} date elements")
            
            times = soup.select('p.text-base.font-bold[data-testid*="time"]')
            print(f"Found {len(times)} time elements")
            
            sports = soup.select("p.text-base.font-bold[data-testid*='activity-name']")
            print(f"Found {len(sports)} sport elements")
            
            if len(dates) > 0:
                print("Sample dates:", [d.get_text(strip=True) for d in dates[:3]])
                
            return True
            
    except ImportError:
        print("Playwright not installed")
        print("Install with: pip install playwright")
        print("Then run: playwright install chromium")
        return False
    except Exception as e:
        print(f"Playwright failed: {e}")
        return False

def sync_scrape_with_playwright():
    """
    Synchronous wrapper for the async function
    """
    return asyncio.run(scrape_with_playwright())

if __name__ == "__main__":
    print("=== Memory-Efficient Playwright Test ===")
    print("This should work better on low-memory Pi")
    print()
    
    success = sync_scrape_with_playwright()
    
    if not success:
        print("\n=== Installation Instructions ===")
        print("Run these commands:")
        print("pip install playwright")
        print("playwright install chromium")
        print()
        print("If you get memory errors, try:")
        print("sudo systemctl stop unnecessary-services")
        print("sudo swapoff -a && sudo swapon -a  # Clear swap")

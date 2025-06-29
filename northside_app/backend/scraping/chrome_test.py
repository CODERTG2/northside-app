# Chrome-based scraping for Raspberry Pi
from bs4 import BeautifulSoup
import requests
import time
import os

def use_chrome_selenium():
    """
    Try Chrome/Chromium instead of Firefox
    """
    print("Trying Chrome/Chromium approach...")
    
    try:
        from selenium import webdriver
        from selenium.webdriver.chrome.options import Options
        from selenium.webdriver.chrome.service import Service
        from selenium.common.exceptions import WebDriverException
        import signal
        
        # Chrome options for Raspberry Pi
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--disable-software-rasterizer")
        chrome_options.add_argument("--disable-background-timer-throttling")
        chrome_options.add_argument("--disable-backgrounding-occluded-windows")
        chrome_options.add_argument("--disable-renderer-backgrounding")
        chrome_options.add_argument("--disable-features=TranslateUI")
        chrome_options.add_argument("--disable-extensions")
        chrome_options.add_argument("--disable-plugins")
        chrome_options.add_argument("--disable-images")
        chrome_options.add_argument("--disable-javascript")  # Start without JS
        chrome_options.add_argument("--memory-pressure-off")
        chrome_options.add_argument("--max_old_space_size=256")
        chrome_options.add_argument("--window-size=1280,720")
        
        # Try different Chrome/Chromium paths
        possible_browsers = [
            "chromium-browser",
            "chromium",
            "google-chrome",
            "chrome"
        ]
        
        possible_drivers = [
            "/usr/bin/chromedriver",
            "/usr/local/bin/chromedriver",
            "/opt/chromedriver",
            "chromedriver"
        ]
        
        # Find browser
        browser_path = None
        for browser in possible_browsers:
            result = os.system(f"which {browser} > /dev/null 2>&1")
            if result == 0:
                chrome_options.binary_location = browser
                browser_path = browser
                print(f"Found browser: {browser}")
                break
        
        if not browser_path:
            print("No Chrome/Chromium browser found")
            print("Install with: sudo apt install chromium-browser")
            return False
        
        # Find driver
        driver_path = None
        for path in possible_drivers:
            if path == "chromedriver":
                result = os.system("which chromedriver > /dev/null 2>&1")
                if result == 0:
                    driver_path = "chromedriver"
                    break
            elif os.path.exists(path):
                driver_path = path
                break
        
        if not driver_path:
            print("No chromedriver found")
            print("Install with: sudo apt install chromium-chromedriver")
            return False
        
        print(f"Using driver: {driver_path}")
        
        # Create service
        if driver_path == "chromedriver":
            service = Service()
        else:
            service = Service(executable_path=driver_path)
        
        def timeout_handler(signum, frame):
            raise TimeoutError("Chrome startup timed out")
        
        signal.signal(signal.SIGALRM, timeout_handler)
        signal.alarm(30)
        
        try:
            print("Creating Chrome driver...")
            driver = webdriver.Chrome(options=chrome_options, service=service)
            signal.alarm(0)
            print("✓ Chrome driver created successfully!")
            
            print("Testing navigation...")
            driver.get("https://httpbin.org/html")
            print(f"Test page title: {driver.title}")
            
            print("Trying target URL...")
            driver.get("https://www.northsideprepathletics.com/schedule?year=2025-2026")
            print("✓ Navigation successful!")
            
            # Get initial content
            html = driver.page_source
            print(f"Initial page length: {len(html)}")
            
            driver.quit()
            return True
            
        except TimeoutError:
            print("✗ Chrome startup timed out")
            signal.alarm(0)
            return False
            
    except ImportError:
        print("Selenium not available for Chrome")
        return False
    except Exception as e:
        print(f"Chrome approach failed: {e}")
        return False

def install_chrome_setup():
    """
    Instructions for installing Chrome setup on Pi
    """
    print("\n=== Chrome Installation Instructions ===")
    print("Run these commands on your Raspberry Pi:")
    print()
    print("# Install Chromium browser and driver")
    print("sudo apt update")
    print("sudo apt install chromium-browser chromium-chromedriver")
    print()
    print("# Verify installation")
    print("chromium-browser --version")
    print("chromedriver --version")
    print()
    print("# If chromedriver is not found, try:")
    print("sudo ln -s /usr/lib/chromium-browser/chromedriver /usr/local/bin/chromedriver")

if __name__ == "__main__":
    print("=== Chrome-based Scraping Test ===")
    
    success = use_chrome_selenium()
    
    if not success:
        install_chrome_setup()

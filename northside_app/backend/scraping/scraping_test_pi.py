# Raspberry Pi optimized scraping script
from bs4 import BeautifulSoup
import requests
import time
import os

def update_athletics_schedule_simple():
    """
    Simple version using requests + BeautifulSoup for initial testing
    """
    print("Updating athletics schedule (simple version)...")
    
    try:
        # Try simple requests first to see if the page loads any content
        headers = {
            'User-Agent': 'Mozilla/5.0 (X11; Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        
        print("Making request to URL...")
        response = requests.get("https://www.northsideprepathletics.com/schedule?year=2025-2026", headers=headers)
        print(f"Response status: {response.status_code}")
        
        if response.status_code == 200:
            soup = BeautifulSoup(response.content, 'html.parser')
            print(f"Page content length: {len(response.content)}")
            
            # Check if we can find any schedule elements
            schedule_elements = soup.find_all(['h3', 'h2', 'p'], class_=True)
            print(f"Found {len(schedule_elements)} elements with classes")
            
            if len(schedule_elements) < 10:
                print("Not enough content found - likely needs JavaScript rendering")
                return use_selenium_fallback()
            else:
                print("Found content, but may need selenium for dynamic loading")
                return use_selenium_fallback()
        else:
            print(f"Failed to fetch page: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"Error with simple request: {e}")
        return use_selenium_fallback()

def use_selenium_fallback():
    """
    Use selenium with better Raspberry Pi configuration
    """
    print("Trying Selenium approach...")
    
    try:
        from selenium import webdriver
        from selenium.webdriver.firefox.options import Options as FirefoxOptions
        from selenium.webdriver.firefox.service import Service as FirefoxService
        from selenium.common.exceptions import WebDriverException
        
        # Firefox options optimized for Raspberry Pi
        firefox_options = FirefoxOptions()
        firefox_options.add_argument("--headless")
        firefox_options.add_argument("--no-sandbox")
        firefox_options.add_argument("--disable-dev-shm-usage")
        firefox_options.add_argument("--disable-gpu")
        firefox_options.add_argument("--window-size=1920,1080")
        firefox_options.add_argument("--disable-extensions")
        firefox_options.add_argument("--disable-plugins")
        firefox_options.add_argument("--disable-images")  # Save memory
        
        # Try different geckodriver paths
        possible_paths = [
            "/usr/local/bin/geckodriver",
            "/usr/bin/geckodriver",
            "/opt/geckodriver",
            "geckodriver"
        ]
        
        driver = None
        for path in possible_paths:
            try:
                print(f"Trying geckodriver at: {path}")
                if path == "geckodriver" or os.path.exists(path):
                    if path == "geckodriver":
                        # Try system path
                        service = FirefoxService(log_path='/dev/null')
                    else:
                        service = FirefoxService(executable_path=path, log_path='/dev/null')
                    
                    driver = webdriver.Firefox(options=firefox_options, service=service)
                    print(f"Successfully created driver with {path}")
                    break
                else:
                    print(f"Path does not exist: {path}")
            except Exception as e:
                print(f"Failed with {path}: {e}")
                continue
        
        if not driver:
            print("Could not create Firefox driver")
            return False
        
        print("Driver created, navigating to URL...")
        driver.get("https://www.northsideprepathletics.com/schedule?year=2025-2026")
        print("driver set up - starting scroll")
        
        # Scroll with more conservative timing for Pi
        last_height = driver.execute_script("return document.body.scrollHeight")
        scroll_attempts = 0
        max_scrolls = 20  # Limit scrolls to prevent infinite loops
        
        while scroll_attempts < max_scrolls:
            driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            time.sleep(3)  # Longer wait for Pi
            print(f"Scroll attempt {scroll_attempts + 1}")
            
            new_height = driver.execute_script("return document.body.scrollHeight")
            if new_height == last_height:
                print("Reached the bottom of the page")
                break
            last_height = new_height
            scroll_attempts += 1
        
        html_content = driver.page_source
        driver.quit()
        
        # Parse the content
        soup = BeautifulSoup(html_content, 'html.parser')
        
        repeated_dates = soup.find_all('h3', class_='uppercase')
        exact_dates = [h3 for h3 in repeated_dates if h3.get('class') == ['uppercase']]
        dates = [h3.get_text(strip=True) for h3 in exact_dates]
        
        print(f"Found {len(dates)} dates")
        if len(dates) > 0:
            print("Sample dates:", dates[:3])
        
        return True
        
    except ImportError:
        print("Selenium not installed. Install with: pip install selenium")
        return False
    except Exception as e:
        print(f"Selenium error: {e}")
        return False

def check_system_requirements():
    """
    Check if required drivers and browsers are installed
    """
    print("Checking system requirements...")
    
    # Check for Firefox
    firefox_check = os.system("which firefox > /dev/null 2>&1")
    print(f"Firefox installed: {'Yes' if firefox_check == 0 else 'No'}")
    
    # Check for geckodriver
    gecko_check = os.system("which geckodriver > /dev/null 2>&1")
    print(f"Geckodriver in PATH: {'Yes' if gecko_check == 0 else 'No'}")
    
    # Check specific paths
    paths_to_check = [
        "/usr/local/bin/geckodriver",
        "/usr/bin/geckodriver",
        "/opt/geckodriver"
    ]
    
    for path in paths_to_check:
        exists = os.path.exists(path)
        print(f"Geckodriver at {path}: {'Yes' if exists else 'No'}")

if __name__ == "__main__":
    check_system_requirements()
    print("-" * 50)
    update_athletics_schedule_simple()

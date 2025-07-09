import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from bs4 import BeautifulSoup
import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
import time

from mongoengine import connect
from dotenv import load_dotenv

def update_track_and_field():
    for year in [2025, 2026]:
        try:
            load_dotenv()
            connect(host=os.environ['MONGODB_URL'])
        except Exception as e:
            print(f"Error connecting to the database: {e}")
        url = f"https://www.athletic.net/team/19718/cross-country/{year}"

        chrome_options = Options()
        # chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--window-size=1920,1080")
        driver = webdriver.Chrome(options=chrome_options)
        driver.get(url)

        # Wait for page to load completely
        wait = WebDriverWait(driver, 20)
        
        # Wait for events to load
        print("Waiting for events to load...")
        time.sleep(10)
        
        # Try multiple selectors to find clickable events
        selectors_to_try = [
            "div.px-2.w-100.d-flex.pointer",
            "div[class*='px-2'][class*='pointer']",
            "div.cal-item[class*='ng-tns']",
            "[class*='cal-item'][class*='ng-star-inserted']"
        ]
        
        clickable_events = []
        for selector in selectors_to_try:
            try:
                elements = driver.find_elements(By.CSS_SELECTOR, selector)
                if elements:
                    print(f"Found {len(elements)} elements with selector: {selector}")
                    clickable_events = elements
                    break
            except Exception as e:
                print(f"Selector {selector} failed: {e}")
                continue
        
        if not clickable_events:
            print("No clickable events found with any selector")
            driver.quit()
            continue

        # Get initial page data
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        events = soup.select('div.px-2.w-100.d-flex.pointer')
        names = [event.find('span', class_="title").get_text(strip=True) for event in events if event.find('span', class_="title")]
        dates = [event.find('small', class_="date").get_text(strip=True) for event in events if event.find('small', class_="date")]

        locations = []
        print(f"Found {len(clickable_events)} clickable events")
        
        for i, clickable_event in enumerate(clickable_events):
            try:
                print(f"Attempting to click event {i+1}")
                
                # Scroll element into view
                driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", clickable_event)
                time.sleep(2)
                
                # Wait for element to be clickable
                wait.until(EC.element_to_be_clickable(clickable_event))
                
                # Try regular click first
                try:
                    clickable_event.click()
                except Exception as click_error:
                    print(f"Regular click failed, trying JavaScript click: {click_error}")
                    # If regular click fails, try JavaScript click
                    driver.execute_script("arguments[0].click();", clickable_event)
                
                # Wait for modal/details to open
                time.sleep(3)
                
                # Get updated page source
                soup = BeautifulSoup(driver.page_source, 'html.parser')
                
                # Look for opened event details with multiple possible selectors
                location_selectors = [
                    'div.cal-item.ng-tns-c342766986-3.ng-star-inserted.item-open',
                    'div[class*="item-open"]',
                    'div[class*="cal-item"][class*="item-open"]'
                ]
                
                location_found = False
                for loc_selector in location_selectors:
                    open_events = soup.select(loc_selector)
                    if open_events:
                        print(f"Found open event with selector: {loc_selector}")
                        for event in open_events:
                            location_link = event.find('meet-venue-link')
                            location_link = location_link.find('a')
                            if location_link:
                                location = location_link.get_text(strip=True)
                                locations.append(location)
                                print(f"Found location: {location}")
                                location_found = True
                        break
                
                if not location_found:
                    print("No location found for this event")
                    locations.append("Location not found")
                
                # Close the modal by clicking elsewhere or pressing escape
                try:
                    driver.execute_script("document.body.click();")
                    time.sleep(1)
                except:
                    pass

            except Exception as e:
                print(f"Error clicking event {i+1}: {e}")
                locations.append("Error retrieving location")

        print(names)
        print(dates)
        print(locations)

        driver.quit()

update_track_and_field()
# import sys
# import os
# sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from bs4 import BeautifulSoup
import requests

# from backend.models.AthleticsSchedule import AthleticsSchedule
# from mongoengine import connect
# from dotenv import load_dotenv

from selenium import webdriver
import time
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.webdriver.firefox.service import Service as FirefoxService
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.chrome.service import Service as ChromeService
import platform
import os

# Setup for Firefox
firefox_options = FirefoxOptions()
firefox_options.add_argument("--headless")
firefox_options.add_argument("--no-sandbox")
firefox_options.add_argument("--disable-dev-shm-usage")

# Setup for Chrome (fallback)
chrome_options = ChromeOptions()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")
chrome_options.add_argument("--disable-gpu")

# Determine paths based on system
system = platform.system().lower()
machine = platform.machine().lower()

if system == "linux" and ("arm" in machine or "aarch64" in machine):
    # Raspberry Pi paths
    firefox_driver_path = "/usr/local/bin/geckodriver"
    chrome_driver_path = "/usr/local/bin/chromedriver"
else:
    # macOS/other paths
    firefox_driver_path = "/usr/local/bin/geckodriver"
    chrome_driver_path = "/usr/local/bin/chromedriver"

def create_webdriver():
    """Try to create a webdriver, with fallbacks"""
    
    # Try Firefox first
    try:
        print("Trying Firefox WebDriver...")
        if os.path.exists(firefox_driver_path):
            service = FirefoxService(executable_path=firefox_driver_path, log_path='/dev/null')
            driver = webdriver.Firefox(options=firefox_options, service=service)
            print("Firefox WebDriver created successfully")
            return driver
        else:
            print(f"Firefox driver not found at {firefox_driver_path}")
    except Exception as e:
        print(f"Firefox WebDriver failed: {e}")
    
    # Try Chrome as fallback
    try:
        print("Trying Chrome WebDriver...")
        if os.path.exists(chrome_driver_path):
            service = ChromeService(executable_path=chrome_driver_path)
            driver = webdriver.Chrome(options=chrome_options, service=service)
            print("Chrome WebDriver created successfully")
            return driver
        else:
            print(f"Chrome driver not found at {chrome_driver_path}")
    except Exception as e:
        print(f"Chrome WebDriver failed: {e}")
    
    # Try system-installed drivers
    try:
        print("Trying system Chrome...")
        driver = webdriver.Chrome(options=chrome_options)
        print("System Chrome WebDriver created successfully")
        return driver
    except Exception as e:
        print(f"System Chrome failed: {e}")
    
    try:
        print("Trying system Firefox...")
        driver = webdriver.Firefox(options=firefox_options)
        print("System Firefox WebDriver created successfully")
        return driver
    except Exception as e:
        print(f"System Firefox failed: {e}")
    
    raise Exception("No WebDriver could be created")

def update_athletics_schedule():
    """
    Scrapes the athletics schedule from the Northside Prep Athletics website
    and updates the database with new events.
    """

    print("Updating athletics schedule...")
    # try:
    #     load_dotenv()
    #     connect(host=os.environ['MONGODB_URL'])
    # except Exception as e:
    #     print(f"Error connecting to the database: {e}")
    #     return
    
    try:
        print("Attempting to create WebDriver...")
        driver = create_webdriver()
        print("WebDriver created successfully")
        
        print("Navigating to URL...")
        driver.get("https://www.northsideprepathletics.com/schedule?year=2025-2026")
        print("driver set up")
    except Exception as e:
        print(f"Error setting up WebDriver: {e}")
        print("Please install a web driver (Firefox geckodriver or Chrome chromedriver)")
        return
    last_height = driver.execute_script("return document.body.scrollHeight")
    print("starting while loop")
    while True:
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")

        time.sleep(5)
        print("scrolling down")

        new_height = driver.execute_script("return document.body.scrollHeight")
        if new_height == last_height:
            print("Reached the bottom of the page")
            break
        last_height = new_height

    html_content = driver.page_source
    
    driver.quit()

    soup = BeautifulSoup(html_content, 'html.parser')

    repeated_dates = soup.find_all('h3', class_='uppercase')
    exact_dates = [h3 for h3 in repeated_dates if h3.get('class') == ['uppercase']]
    dates = [h3.get_text(strip=True) for h3 in exact_dates]
    # print(dates)

    times = soup.select('p.text-base.font-bold[data-testid*="time"]')
    times = [p.get_text(strip=True) for p in times]
    # print(times)

    sports = soup.select("p.text-base.font-bold[data-testid*='activity-name']")
    sports = [p.get_text(strip=True) for p in sports]
    # print(sports)

    locations = soup.select("p.text-sm.font-medium[data-testid*='venue']")
    locations = [p.get_text(strip=True) for p in locations]
    # print(locations)

    teams = soup.select("div.text-sm.font-medium.text-core-contrast.text-opacity-80.xl\\:text-base[data-testid*='gender-level']")
    teams = [p.get_text(strip=True) for p in teams]
    # print(teams)

    opponents = soup.select('h2.mb-1.font-heading.text-xl')
    opponents = [h2.get_text(strip=True).replace("vs ", "").replace("at ", "") for h2 in opponents]
    # print(opponents)

    home = soup.select("div.inline-flex.items-center.gap-1")
    home = [div.get_text(strip=True) for div in home]
    home = [item.lower() == "home" for item in home]
    # print(home)

    length = len(dates)
    schedule = []
    added_count = 0
    existing_count = 0

    for i in range(length):
        
        event_data = {
            "date": dates[i],
            "time": times[i],
            "sport": sports[i],
            "team": teams[i],
            "opponent": opponents[i],
            "location": locations[i],
            "home": home[i]
        }
        schedule.append(event_data)
        
        # existing_event = AthleticsSchedule.objects(
        #     date=dates[i],
        #     time=times[i],
        #     sport=sports[i],
        #     team=teams[i],
        #     opponent=opponents[i],
        #     location=locations[i],
        #     home=home[i]
        # ).first()
        
        # if not existing_event:
        #     event = AthleticsSchedule(
        #         date=dates[i],
        #         time=times[i],
        #         sport=sports[i],
        #         team=teams[i],
        #         opponent=opponents[i],
        #         location=locations[i],
        #         home=home[i]
        #     )
        #     event.save()
        #     added_count += 1
        # else:
        #     existing_count += 1

    # print(f"Athletics schedule updated: {added_count} new events added, {existing_count} events already existed")
    print(schedule)

update_athletics_schedule()
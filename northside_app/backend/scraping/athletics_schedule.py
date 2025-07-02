import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from bs4 import BeautifulSoup
import requests

from backend.models.AthleticsSchedule import AthleticsSchedule
from mongoengine import connect
from dotenv import load_dotenv

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time

chrome_options = Options()
chrome_options.add_argument("--headless")

def update_athletics_schedule():
    """
    Scrapes the athletics schedule from the Northside Prep Athletics website
    and updates the database with new events.
    """

    print("Updating athletics schedule...")
    try:
        load_dotenv()
        connect(host=os.environ['MONGODB_URL'])
    except Exception as e:
        print(f"Error connecting to the database: {e}")
        return
    
    url = "https://www.northsideprepathletics.com/schedule?year=2025-2026"
    driver = webdriver.Chrome(options=chrome_options)
    driver.get(url)
    
    time.sleep(5)
    
    print("Page loaded, starting to scroll...")
    
    previous_event_count = 0
    no_new_content_count = 0
    max_scroll_attempts = 20
    scroll_attempt = 0
    
    while scroll_attempt < max_scroll_attempts:
        current_events = driver.find_elements("css selector", "h2.mb-1.font-heading.text-xl")
        current_event_count = len(current_events)
        
        print(f"Scroll attempt {scroll_attempt + 1}: Found {current_event_count} events")
        
        driver.execute_script("window.scrollBy(0, 1000);")
        time.sleep(2)
        
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(5)
        
        new_events = driver.find_elements("css selector", "h2.mb-1.font-heading.text-xl")
        new_event_count = len(new_events)
        
        if new_event_count == current_event_count:
            no_new_content_count += 1
            print(f"No new content loaded (attempt {no_new_content_count})")
            
            if no_new_content_count >= 3:
                print("No new content for 3 attempts, assuming all content loaded")
                break
        else:
            no_new_content_count = 0
            print(f"New content loaded: {new_event_count - current_event_count} new events")
        
        previous_event_count = new_event_count
        scroll_attempt += 1
    
    print(f"Finished scrolling after {scroll_attempt} attempts. Final event count: {len(driver.find_elements('css selector', 'h2.mb-1.font-heading.text-xl'))}")
    
    time.sleep(5)
    html_content = driver.page_source
    driver.quit()

    soup = BeautifulSoup(html_content, 'html.parser')

    repeated_dates = soup.find_all('h3', class_='uppercase')
    exact_dates = [h3 for h3 in repeated_dates if h3.get('class') == ['uppercase']]
    dates = [h3.get_text(strip=True) for h3 in exact_dates]
    # print(f"Found {len(dates)} dates")

    times = soup.select('p.text-base.font-bold[data-testid*="time"]')
    times = [p.get_text(strip=True) for p in times]
    # print(f"Found {len(times)} times")

    sports = soup.select("p.text-base.font-bold[data-testid*='activity-name']")
    sports = [p.get_text(strip=True) for p in sports]
    # print(f"Found {len(sports)} sports")

    locations = soup.select("p.text-sm.font-medium[data-testid*='venue']")
    locations = [p.get_text(strip=True) for p in locations]
    # print(f"Found {len(locations)} locations")

    levels = soup.select("div.text-sm.font-medium.text-core-contrast.text-opacity-80.xl\\:text-base[data-testid*='gender-level']")
    levels = [p.get_text(strip=True).split()[1] for p in levels]
    # print(f"Found {len(teams)} teams")

    genders = soup.select("div.text-sm.font-medium.text-core-contrast.text-opacity-80.xl\\:text-base[data-testid*='gender-level']")
    genders = [p.get_text(strip=True).split()[0] for p in genders] 

    opponents = soup.select('h2.mb-1.font-heading.text-xl')
    opponents = [h2.get_text(strip=True).replace("vs ", "").replace("at ", "") for h2 in opponents]
    # print(f"Found {len(opponents)} opponents")

    home = soup.select("div.inline-flex.items-center.gap-1")
    home = [div.get_text(strip=True) for div in home]
    home = [item.lower() == "home" for item in home]
    # print(f"Found {len(home)} home/away indicators")
    
    length = len(dates)
    # print(f"Processing {length} events")
    added_count = 0

    if AthleticsSchedule.objects.count() >= length:
        return
    else:
        AthleticsSchedule.drop_collection()

    for i in range(length):
        event = AthleticsSchedule(
            date=dates[i],
            time=times[i],
            gender=genders[i],
            sport=sports[i],
            level=levels[i],
            opponent=opponents[i],
            location=locations[i],
            home=home[i]
        )
        event.save()
        added_count += 1

    print(f"Athletics schedule updated: {added_count} new events added")
    # print(schedule)

# update_athletics_schedule()
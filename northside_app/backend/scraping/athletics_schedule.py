import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from bs4 import BeautifulSoup
import requests
from backend.models.AthleticsSchedule import AthleticsSchedule
from mongoengine import connect
from dotenv import load_dotenv

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
    response = requests.get(url)
    html_content = response.text

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

    home = soup.select("div.inline-flex.items-center.gap-1")
    home = [div.get_text(strip=True) for div in home]
    home = [item == "Home" for item in home]
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
            "location": locations[i],
            "home": home[i]
        }
        schedule.append(event_data)
        
        existing_event = AthleticsSchedule.objects(
            date=dates[i],
            time=times[i],
            sport=sports[i],
            team=teams[i],
            location=locations[i],
            home=home[i]
        ).first()
        
        if not existing_event:
            event = AthleticsSchedule(
                date=dates[i],
                time=times[i],
                sport=sports[i],
                team=teams[i],
                location=locations[i],
                home=home[i]
            )
            event.save()
            added_count += 1
        else:
            existing_count += 1

    print(f"Athletics schedule updated: {added_count} new events added, {existing_count} events already existed")

update_athletics_schedule()
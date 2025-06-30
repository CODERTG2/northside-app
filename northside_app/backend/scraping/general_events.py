import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from bs4 import BeautifulSoup
import requests
from datetime import datetime

from backend.models.GeneralEvent import GeneralEvent
from mongoengine import connect
from dotenv import load_dotenv

def update_general_events():
    print("Updating general events...")

    try:
        load_dotenv()
        connect(host=os.environ['MONGODB_URL'])
    except Exception as e:
        print(f"Error connecting to the database: {e}")

    
    schedule = []
    
    origin = "Northside Prep School Calendar"
    
    for month_num in range(1, 13):
        for year_num in range(2025, 2027):
            url = f"https://www.northsideprep.org/apps/events/view_calendar.jsp?id=0&m={month_num-1}&y={year_num}"
            try:
                response = requests.get(url)
                response.raise_for_status()
            except requests.RequestException as e:
                print(f"Error fetching {url}: {e}")
                continue

            html_content = response.content

            soup = BeautifulSoup(html_content, 'html.parser')
            event_cells = soup.find_all('div', class_='day prev') + soup.find_all('div', class_='day prev weekend')

            for cell in event_cells:
                event_name = cell.find("a", class_="eventInfoAnchor")
                if event_name:
                    event_name = event_name.text.strip()
                    event_date = cell.find("span", class_="dayLabel").text.strip()
                    event_date = f"{month_num}/{event_date}/{year_num}"
                    event_time = cell.find("span", class_="edEventDate").text.strip() if cell.find("span", class_="edEventDate") else "All Day"

                    schedule.append({
                        "date": event_date,
                        "time": event_time,
                        "name": event_name,
                        "createdBy": origin
                    })

                    existing_event = GeneralEvent.objects(
                        date=event_date,
                        time=event_time,
                        name=event_name,
                        createdBy=origin
                    ).first()

                    if not existing_event:
                        event = GeneralEvent(
                            date=event_date,
                            time=event_time,
                            name=event_name,
                            createdBy=origin,
                            createdAt=datetime.now()
                        )
                        event.save()
                        added_count += 1
                    else:
                        existing_count += 1
    if GeneralEvent.objects.count() >= len(schedule):
        print("No new events to add, skipping update.")
        return
    else:
        GeneralEvent.drop_collection()
        for event_data in schedule:
            event = GeneralEvent(**event_data)
            event.save()
        print(f"General schedule updated: {len(schedule)} events processed")

# update_general_events()
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
    
    added_count = 0
    existing_count = 0
    origin = "Northside Prep School Calendar"
    
    for month_num in range(0, 12):
        for year_num in range(2025, 2027):
            url = f"https://www.northsideprep.org/apps/events/view_calendar.jsp?id=0&m={month_num}&y={year_num}"
            response = requests.get(url)
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
    print(f"General schedule updated: {added_count} new events added, {existing_count} events already existed")

# update_general_events()
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from backend.gsheets.connection import sheet

from backend.models.GeneralEvent import GeneralEvent
from backend.models.Announcement import Announcement
from mongoengine import connect
from dotenv import load_dotenv

def update_submissions():

    print("Updating submissions...")
    try:
        load_dotenv()
        connect(host=os.environ['MONGODB_URL'])
    except Exception as e:
        print(f"Error connecting to the database: {e}")
        return

    worksheet = sheet.get_worksheet(0)
    data = worksheet.get_all_values()
    columns = data[0]

    existing_events = 0
    added_events = 0

    existing_announcements = 0
    added_announcements = 0

    for row in data[1:]:
        if row[0] != '' and row[-1] == "TRUE":
            if row[3] == "Public Event":

                if row[columns.index("Time")] == "":
                    row[columns.index("Time")] = "All Day"

                existing_event = GeneralEvent.objects(
                    date=row[columns.index("Date")],
                    time=row[columns.index("Time")],
                    name=row[columns.index("Event Title")],
                    description=row[columns.index("Description")],
                    location=row[columns.index("Location")],
                    createdBy=row[columns.index("Hosted by?")]
                ).first()

                if not existing_event:
                    event = GeneralEvent(
                        date=row[columns.index("Date")],
                        time=row[columns.index("Time")],
                        name=row[columns.index("Event Title")],
                        description=row[columns.index("Description")],
                        location=row[columns.index("Location")],
                        createdBy=row[columns.index("Hosted by?")]
                    )
                    event.save()
                    added_events += 1

                else:
                    existing_events += 1
            
            elif row[3] == "Announcement":

                existing_announcement = Announcement.objects(
                    start_date=row[columns.index("Start day of appearance")],
                    end_date=row[columns.index("End day of appearance")],
                    title=row[columns.index("Announcement Title")],
                    description=row[columns.index("Text")],
                    createdBy=row[columns.index("Announcement by who?")]
                ).first()

                if not existing_announcement:
                    announcement = Announcement(
                        start_date=row[columns.index("Start day of appearance")],
                        end_date=row[columns.index("End day of appearance")],
                        title=row[columns.index("Announcement Title")],
                        description=row[columns.index("Text")],
                        createdBy=row[columns.index("Announcement by who?")]
                    )
                    announcement.save()
                    added_announcements += 1

                else:
                    existing_announcements += 1

    print(f"Submissions processed: {added_events} new events added, {existing_events} events already existed")
    print(f"Submissions processed: {added_announcements} new announcements added, {existing_announcements} announcements already existed")

# update_submissions()

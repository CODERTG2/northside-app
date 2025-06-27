from scraping.athletics_schedule import update_athletics_schedule
from scraping.athletics_roster import update_athletics_roster
from scraping.general_events import update_general_events
from gsheets.submissions import update_submissions
from datetime import datetime

def update_data():
    while True:
        if datetime.now().weekday() == 0 and datetime.now().strftime("%H:%M") == "10:00":
            print("Updating general schedule...")
            update_general_events()
            print("General schedule update completed.")
        if datetime.now().day == 1 and datetime.now().strftime("%H:%M") == "11:00":
            print("Updating athletics schedule...")
            update_athletics_roster()
            print("Athletics schedule update completed.")
        if datetime.now().strftime("%H:%M") == "12:00":
            print("Updating athletics schedule...")
            update_athletics_schedule()
            print("Athletics schedule update completed.")
            print("Updating submissions...")
            update_submissions()
            print("Submissions update completed.")
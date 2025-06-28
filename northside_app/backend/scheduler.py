import schedule
import time
import os
from dotenv import load_dotenv
from mongoengine import connect

print("=== SCHEDULER STARTING ===")

from scraping.athletics_schedule import update_athletics_schedule
from scraping.athletics_roster import update_athletics_roster
from scraping.general_events import update_general_events
from gsheets.submissions import update_submissions
print("Imports successful")

load_dotenv()
connect(host=os.environ.get('MONGODB_URL'))
print("Database connected")

schedule.every().hour.do(update_athletics_schedule)
schedule.every().hour.do(update_athletics_roster)
schedule.every().hour.do(update_general_events)
schedule.every().hour.do(update_submissions)

counter = 0

print("=== SCHEDULER CONFIGURED ===")
while True:
    # print(f"{counter}")
    schedule.run_pending()
    counter += 1
    if counter % 300 == 0:
        current_time = time.strftime("%Y-%m-%d %H:%M:%S")
        print(f"Heartbeat: {current_time} - Scheduler running for approximately {counter} seconds")
        counter = 0
    time.sleep(1)

import schedule
import time
import os
from dotenv import load_dotenv
from mongoengine import connect

from scraping.athletics_schedule import update_athletics_schedule
from scraping.athletics_roster import update_athletics_roster
from scraping.general_events import update_general_events
from gsheets.submissions import update_submissions

load_dotenv()
connect(host=os.environ.get('MONGODB_URL'))

schedule.every().day.at("06:00").do(update_athletics_schedule)
schedule.every().day.at("06:30").do(update_athletics_roster)
schedule.every().day.at("07:00").do(update_general_events)
schedule.every().day.at("07:30").do(update_submissions)
    
while True:
    schedule.run_pending()
    time.sleep(1)
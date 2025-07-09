import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from bs4 import BeautifulSoup
import requests
import backend.models.AthleticsSchedule as AthleticsSchedule

from mongoengine import connect
from dotenv import load_dotenv

try:
    load_dotenv()
    connect(host=os.environ['MONGODB_URL'])
except Exception as e:
    print(f"Error connecting to the database: {e}")

def update_athletics_scores():
    for game in AthleticsSchedule.objects:
        url = f"https://www.maxpreps.com/il/chicago/northside-mustangs/{game.sport}/{game.gender}/{game.level}/{game.season}/schedule/"
        try:
            response = requests.get(url, timeout=(10, 30))
            response.raise_for_status()
        except requests.RequestException as e:
            print(f"Error fetching {url}: {e}")
            continue

update_athletics_scores()
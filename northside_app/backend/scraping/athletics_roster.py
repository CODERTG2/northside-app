import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from bs4 import BeautifulSoup
import requests

from backend.models.Athlete import Athlete
from mongoengine import connect
from dotenv import load_dotenv

def update_athletics_roster():

    print("Updating athletics roster...")
    try:
        load_dotenv()
        connect(host=os.environ['MONGODB_URL'])
    except Exception as e:
        print(f"Error connecting to the database: {e}")
        return
    
    url = "https://www.maxpreps.com/il/chicago/northside-mustangs/"
    response = requests.get(url)
    html_content = response.text

    soup = BeautifulSoup(html_content, 'html.parser')
    sports = soup.find_all('span', class_="sport-name")
    sports = [sport.get_text(strip=True).replace("& ", "").replace(" ", "-").lower() for sport in sports]
    sports = list(set(sports))

    genders = ["girls", "boys"]
    seasons = ["fall", "winter", "spring"]
    levels = ["varsity", "jv", "freshman"]

    added_count = 0
    existing_count = 0

    for sport in sports:
        for gender in genders:
            for season in seasons:
                for level in levels:
                    url = f"https://www.maxpreps.com/il/chicago/northside-mustangs/{sport}/{gender}/{level}/{season}/roster/"
                    # url = f"https://www.maxpreps.com/il/chicago/northside-mustangs/{sport}/{gender}/{level}/{season}/24-25/roster/"
                    try:
                        response = requests.get(url)
                        response.raise_for_status()
                    except requests.RequestException as e:
                        print(f"Error fetching {url}: {e}")
                        continue

                    html_content = response.text
                    soup = BeautifulSoup(html_content, 'html.parser')

                    players = soup.find_all('a', class_="sc-51f90f89-0 hcqeYd name")
                    players = [player.get_text(strip=True) for player in players]
                    if players:
                        # print(players)

                        primary_tds = soup.find_all("td", class_="primary")
                        grades = []
                        positions = []
                        numbers = []
                        for td in primary_tds:
                            grade_td = td.find_next_sibling("td")
                            if grade_td:
                                grades.append(grade_td.get_text(strip=True))
                                position_td = grade_td.find_next_sibling("td")
                                if position_td:
                                    positions.append(position_td.get_text(strip=True))
                                else:
                                    positions.append("N/A")
                                number_td = td.find_previous_sibling("td")
                                if number_td:
                                    number = number_td.get_text(strip=True)
                                    numbers.append(int(number) if number.isdigit() else 0)
                                else:
                                    numbers.append(0)

                        # print(grades)
                        # print(positions)
                        for player in players:
                            existing_athlete = Athlete.objects(
                                name=player,
                                number=numbers[players.index(player)],
                                sport=sport,
                                level=level,
                                gender=gender,
                                grade=grades[players.index(player)],
                                position=positions[players.index(player)]
                            ).first()
                            if not existing_athlete:
                                athlete = Athlete(
                                    name=player,
                                    number=numbers[players.index(player)],
                                    sport=sport,
                                    level=level,
                                    gender=gender,
                                    grade=grades[players.index(player)],
                                    position=positions[players.index(player)]
                                )
                                athlete.save()
                                added_count += 1
                            else:
                                existing_count += 1

    print(f"Added {added_count} athletes, existing {existing_count} athletes.")

# update_athletics_roster()
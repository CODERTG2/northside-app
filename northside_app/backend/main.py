from flask import Flask, request, jsonify
from flask_cors import CORS
# import threading
# from dataUpdate import update_data
from mongoengine import connect
import os
from dotenv import load_dotenv

from models.Athlete import Athlete
from models.AthleticsSchedule import AthleticsSchedule
from models.GeneralEvent import GeneralEvent
from models.Announcement import Announcement
from carousel import tenevents

app = Flask(__name__)
CORS(app)

load_dotenv()
connect(host=os.environ.get('MONGODB_URL'))

@app.route('/api/roster', methods=['GET'])
def roster():
    try:
        sport = request.args.get('sport')
        gender = request.args.get('gender')
        level = request.args.get('level')

        query = {}
        if sport:
            query['sport'] = sport
        if gender:
            query['gender'] = gender
        if level:
            query['level'] = level
        
        athletes = Athlete.objects(**query).to_json()
        return athletes
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/schedule/athletics', methods=['GET'])
def schedule():
    try:
        sport = request.args.get('sport')
        season = request.args.get('season')
        gender = request.args.get('gender')
        level = request.args.get('level')
        date = request.args.get('date')
        time = request.args.get('time')
        home = request.args.get('home')
        name = request.args.get('name')

        query = {}
        if sport:
            query['sport'] = sport
        if season:
            query['season'] = season
        if gender:
            query['gender'] = gender
        if level:
            query['level'] = level
        if date:
            query['date'] = date
        if time:
            query['time'] = time
        if home:
            query['home'] = home
        if name:
            query['name'] = name
        
        events = AthleticsSchedule.objects(**query).to_json()
        return events
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@app.route('/api/schedule/general', methods=['GET'])
def general_schedule():
    try:
        date = request.args.get('date')
        time = request.args.get('time')
        name = request.args.get('name')

        query = {}
        if date:
            query['date'] = date
        if time:
            query['time'] = time
        if name:
            query['name'] = name
        
        events = GeneralEvent.objects(**query).to_json()
        return events
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@app.route('/api/announcements', methods=['GET'])
def announcements():
    try:
        date = request.args.get('date')

        query = {}
        if date:
            query['start_date'] = date
        
        announcements = Announcement.objects(**query).to_json()
        return announcements
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@app.route('/api/home', methods=['GET'])
def home():
    try:
        announcements = [announcement.to_mongo().to_dict() for announcement in Announcement.objects().exclude('id')]
        events = [event.to_mongo().to_dict() for event in GeneralEvent.objects().exclude('id')]
        athletics_schedule = [schedule.to_mongo().to_dict() for schedule in AthleticsSchedule.objects().exclude('id')]
        carousel = tenevents(announcements, events, athletics_schedule)
        return jsonify(carousel)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # tdataupdate = threading.Thread(target=update_data)
    # tdataupdate.start()

    app.run()

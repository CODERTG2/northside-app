from flask import Flask, request, jsonify
from flask_cors import CORS
import threading
from dataUpdate import update_data
from mongoengine import connect
import os
from dotenv import load_dotenv

from models.Athlete import Athlete
from models.AthleticsSchedule import AthleticsSchedule

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

@app.route('/api/schedule', methods=['GET'])
def schedule():
    try:
        sport = request.args.get('sport')
        team = request.args.get('team')
        date = request.args.get('date')
        time = request.args.get('time')
        home = request.args.get('home')

        query = {}
        if sport:
            query['sport'] = sport
        if team:
            query['team'] = team
        if date:
            query['date'] = date
        if time:
            query['time'] = time
        if home:
            query['home'] = home
        
        events = AthleticsSchedule.objects(**query).to_json()
        return events
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    tdataupdate = threading.Thread(target=update_data)
    tdataupdate.start()

    app.run(debug=True)

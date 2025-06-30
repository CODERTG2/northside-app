from mongoengine import Document, StringField, DateTimeField, BooleanField
from datetime import datetime

class AthleticsSchedule(Document):
    date = StringField(required=True)
    time = StringField(required=True)
    gender = StringField(required=True)
    sport = StringField(required=True)
    level = StringField(required=True)
    opponent = StringField(required=True)
    location = StringField(required=True)
    home = BooleanField(required=True)
    createdAt = DateTimeField(required=True, default=datetime.now)    

    meta = {
        'collection': 'athletics_schedule',
        'indexes': [
            {'fields': ['date', 'time', 'gender', 'sport', 'level', 'opponent', 'location', 'home', 'createdAt'], 'unique': True}
        ]
    }
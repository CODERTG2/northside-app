from mongoengine import Document, StringField, DateTimeField, BooleanField
from datetime import datetime

class Announcement(Document):
    start_date = StringField(required=True)
    end_date = StringField(required=True)
    title = StringField(required=True)
    description = StringField(required=False)
    createdBy = StringField(required=True)
    createdAt = DateTimeField(required=True, default=datetime.now)    

    meta = {
        'collection': 'announcements',
        'indexes': [
            {'fields': ['start_date', 'end_date', 'title', 'description', 'createdBy', 'createdAt'], 'unique': True}
        ]
    }
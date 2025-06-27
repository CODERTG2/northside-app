from mongoengine import Document, StringField, DateTimeField, BooleanField
from datetime import datetime

class Announcement(Document):
    date = StringField(required=True)
    title = StringField(required=True)
    description = StringField(required=False)
    createdBy = StringField(required=True)
    createdAt = DateTimeField(required=True, default=datetime.now)    

    meta = {
        'collection': 'announcements',
        'indexes': [
            {'fields': ['date', 'title', 'description', 'createdBy', 'createdAt'], 'unique': True}
        ]
    }
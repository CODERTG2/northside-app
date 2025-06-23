import gspread
from google.oauth2.service_account import Credentials

scopes = [
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive'
]

cred = Credentials.from_service_account_file("credentials.json", scopes=scopes)
client = gspread.authorize(cred)

sheets_id = "1BMQKu_fMxIr0HhoZxao4OxSxEUbKHR8lsqe5EyU3zAM"
sheet = client.open_by_key(sheets_id)
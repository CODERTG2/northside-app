import gspread
from google.oauth2.service_account import Credentials
import os

scopes = [
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive'
]

script_dir = os.path.dirname(os.path.abspath(__file__))
credentials_path = os.path.join(script_dir, "credentials.json")

cred = Credentials.from_service_account_file(credentials_path, scopes=scopes)
client = gspread.authorize(cred)

sheets_id = "1BMQKu_fMxIr0HhoZxao4OxSxEUbKHR8lsqe5EyU3zAM"
sheet = client.open_by_key(sheets_id)
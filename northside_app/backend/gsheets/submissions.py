from connection import sheet

def get_submissions():
    """
    Fetches all submissions from the Google Sheet.
    
    Returns:
        list: A list of dictionaries representing each submission.
    """
    submissions = []
    worksheet = sheet.get_worksheet(0)
    data = worksheet.get_all_values()
    
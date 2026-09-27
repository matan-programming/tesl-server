import json

# שם קובץ המקור
input_filename = 'cards_db_updated.json' 

# קריאת קובץ ה-JSON
with open(input_filename, 'r', encoding='utf-8') as file:
    cards_data = json.load(file)

# משתנים לשמירת הקלף עם השם הארוך ביותר
longest_name = ""
longest_card_id = ""
max_length = 0

# מעבר על כל הקלפים
for card in cards_data.values():
    current_name = card.get("name", "")
    # דילוג על קלפים מסוג Double Card
    if card.get("type") == "Double Card":
        continue
    
    # בדיקה האם השם הנוכחי ארוך יותר מהמקסימום שמצאנו עד כה
    if current_name and len(current_name) > max_length:
        max_length = len(current_name)
        longest_name = current_name
        longest_card_id = card.get("card_id", "Unknown")

# הדפסת התוצאה
if max_length > 0:
    print(f"השם הארוך ביותר הוא: '{longest_name}'")
    print(f"אורך השם: {max_length} תווים")
    print(f"מזהה הקלף (card_id): {longest_card_id}")
else:
    print("לא נמצאו קלפים עם שדה שם (name).")
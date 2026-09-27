import json

# שם קובץ המקור (אפשר להשתמש בקובץ המעודכן מהשלב הקודם)
input_filename = 'cards_db_updated.json' 
# שם הקובץ החדש שייווצר עם הקלפים שחולצו
output_filename = 'DEBUGGING_example_cards_db.json'

# רשימת המפתחות שאתה רוצה לחלץ
keys_to_extract = [
    'aela_the_huntress', 'aela_s_huntmate', 'abecean_navigator', 
    'abnur_tharn', 'a_land_divided', 'alchemy', 'an_xileel_invader', 
    'apex_predator', 'ald_velothi_assassin', 'almalexia', 
    'a_night_to_remember', 'abandoned_imperfect'
]

# קריאת קובץ ה-JSON
with open(input_filename, 'r', encoding='utf-8') as file:
    all_cards_data = json.load(file)

# יצירת מילון חדש שיכיל רק את הקלפים המבוקשים
extracted_cards = {}

# חילוץ הנתונים
for key in keys_to_extract:
    if key in all_cards_data:
        extracted_cards[key] = all_cards_data[key]
    else:
        print(f"Warning: Key '{key}' not found in the input file.")

# שמירת הנתונים שחולצו לקובץ חדש
with open(output_filename, 'w', encoding='utf-8') as file:
    json.dump(extracted_cards, file, indent=2, ensure_ascii=False)

print(f"\nExtraction complete! Saved {len(extracted_cards)} items to {output_filename}")
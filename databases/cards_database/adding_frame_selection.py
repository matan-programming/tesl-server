import json

# שם קובץ המקור ושם הקובץ החדש שייווצר
input_filename = 'cards_db.json' 
output_filename = 'cards_db_updated.json'

# קריאת קובץ ה-JSON
with open(input_filename, 'r', encoding='utf-8') as file:
    cards_data = json.load(file)

# מעבר על כל האובייקטים (הקלפים) בקובץ
for key, card in cards_data.items():
    
    # חילוץ הנתונים הרלוונטיים לבדיקה
    card_type = card.get("type")
    card_id = card.get("card_id", "")
    card_text = card.get("text")
    
    # לוגיקה לקביעת frame_type
    if card_type == "Double Card":
        card["frame_type"] = "double_frame"
        
    elif card_id.startswith("playing_card_"):
        card["frame_type"] = "no_frame"
        
    else:
        # בדיקת אורך הטקסט (מטפל גם במקרה שהטקסט הוא null)
        text_length = len(card_text) if card_text is not None else 0
        
        if text_length <= 80:
            card["frame_type"] = "standard"
        else:
            card["frame_type"] = "extended_text"

# שמירת הנתונים המעודכנים לקובץ חדש
with open(output_filename, 'w', encoding='utf-8') as file:
    json.dump(cards_data, file, indent=2, ensure_ascii=False)

print(f"Update complete! Saved to {output_filename}")
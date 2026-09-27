import json

# שם קובץ המקור ושם הקובץ החדש שייווצר
input_filename = 'cards_db_updated.json' 
output_filename = 'cards_db_updated_scaling.json'

# קריאת קובץ ה-JSON
with open(input_filename, 'r', encoding='utf-8') as file:
    cards_data = json.load(file)

# מעבר על כל האובייקטים (הקלפים) בקובץ
for key, card in cards_data.items():
    
    # --- הוספת שדות ל-artworks ---
    artworks = card.get("artworks", [])
    for artwork in artworks:
        artwork["offset_x"] = 0
        artwork["offset_y"] = 0
        artwork["scale"] = 1

# שמירת הנתונים המעודכנים לקובץ חדש
with open(output_filename, 'w', encoding='utf-8') as file:
    json.dump(cards_data, file, indent=2, ensure_ascii=False)

print(f"Update complete! Saved to {output_filename}")
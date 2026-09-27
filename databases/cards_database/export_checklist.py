import json

with open('cards_db_updated_scaling.json', 'r', encoding='utf-8') as file:
    data = json.load(file)

sampled_data = {}

# Our checklists
collected_attributes = set()
collected_types = set()
collected_support_types = set()
collected_costs = set()
found_night_mother = False

for key, card in data.items():
    # Enforce the collectible constraint immediately
    if not card.get("is_collectible"):
        continue
        
    added_to_sample = False
    
    # 1. Check for The Night Mother
    if not found_night_mother and card.get("name") == "The Night Mother":
        found_night_mother = True
        added_to_sample = True
        
    # 2. Check for missing Attributes (up to 26)
    attr = card.get("attribute")
    if attr and attr not in collected_attributes:
        collected_attributes.add(attr)
        added_to_sample = True
        
    # 3. Check for missing Types
    c_type = card.get("type")
    if c_type in ["Action", "Item", "Creature", "Support"] and c_type not in collected_types:
        collected_types.add(c_type)
        added_to_sample = True
        
    # 4. Check for missing Support Types
    if c_type == "Support":
        s_type = card.get("support_type")
        if s_type in ["Uses", "Ongoing"] and s_type not in collected_support_types:
            collected_support_types.add(s_type)
            added_to_sample = True
            
    # 5. Check for missing Costs (0 through 13)
    cost = card.get("cost")
    if isinstance(cost, int) and 0 <= cost <= 13 and cost not in collected_costs:
        collected_costs.add(cost)
        added_to_sample = True
        
    # If the card fulfilled any missing requirement, save it to our final JSON
    if added_to_sample:
        sampled_data[key] = card
        
        # Stop early if our checklist is completely full
        if (len(collected_attributes) >= 26 and 
            len(collected_types) == 4 and 
            len(collected_support_types) == 2 and 
            len(collected_costs) == 14 and 
            found_night_mother):
            break 

with open('DEBUGGING_example_cards_db.json', 'w', encoding='utf-8') as file:
    json.dump(sampled_data, file, indent=4)
    
print(f"Sampled {len(sampled_data)} cards.")
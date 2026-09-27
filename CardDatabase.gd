extends Node

## Autoload: CardDatabase
## Loads and manages the card database JSON dictionary.

const DEFAULT_DB_PATH: String = "res://databases/cards_database/DEBUGGING_example_cards_db.json"

var cards: Dictionary = {}
var card_ids: Array = []

func _ready() -> void:
	load_database(DEFAULT_DB_PATH)

## Loads a JSON card database from a path into the `cards` Dictionary.
func load_database(path: String = DEFAULT_DB_PATH) -> bool:
	if not FileAccess.file_exists(path):
		printerr("[CardDatabase] File does not exist: ", path)
		return false

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		var err := FileAccess.get_open_error()
		printerr("[CardDatabase] Failed to open file: ", path, " (Error code: ", err, ")")
		return false

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_text)
	if parse_result != OK:
		printerr("[CardDatabase] Failed to parse JSON in ", path, " at line ", json.get_error_line(), ": ", json.get_error_message())
		return false

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		printerr("[CardDatabase] Root object in JSON is not a Dictionary: ", path)
		return false

	cards = data
	card_ids = cards.keys()
	print("[CardDatabase] Loaded %d cards successfully from: %s" % [cards.size(), path])
	return true

## Returns a random card ID from the loaded database.
func get_random_card_id() -> String:
	if card_ids.is_empty():
		push_warning("[CardDatabase] get_random_card_id called but database is empty!")
		return ""
	var random_index := randi() % card_ids.size()
	return str(card_ids[random_index])

## Returns the dictionary data for a given card ID.
func get_card(card_id: String) -> Dictionary:
	return cards.get(card_id, {})

## Returns whether a card ID exists in the database.
func has_card(card_id: String) -> bool:
	return cards.has(card_id)

## Returns all card IDs.
func get_all_card_ids() -> Array:
	return card_ids.duplicate()

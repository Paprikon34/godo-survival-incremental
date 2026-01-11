extends Node

var debug_enabled: bool = false
var cheats_enabled: bool = false
var fps_enabled: bool = true
var save_data: Dictionary = {
	"gold": 0,
	"upgrades": {
		"health": 0,
		"damage": 0,
		"speed": 0
	}
}

const SAVE_PATH = "user://savegame.save"

signal console_log_emitted(text: String)

func console_log(text: String):
	print(text) # Still print to editor output
	console_log_emitted.emit(text)

func _ready():
	load_data()

func load_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var text = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(text)
		if error == OK:
			var loaded = json.data
			# Merge with default to ensure new keys exist
			for key in save_data:
				if key in loaded:
					if typeof(save_data[key]) == TYPE_DICTIONARY and typeof(loaded[key]) == TYPE_DICTIONARY:
						for k in save_data[key]:
							if k in loaded[key]:
								save_data[key][k] = loaded[key][k]
					else:
						save_data[key] = loaded[key]
		else:
			print("JSON Parse Error: ", json.get_error_message())
	
	# Verify types
	if typeof(save_data.upgrades) != TYPE_DICTIONARY:
		save_data.upgrades = { "health": 0, "damage": 0, "speed": 0 }

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(save_data)
	file.store_string(json_string)

func add_gold(amount: int):
	save_data.gold += amount
	console_log("Gained %d Gold! Total: %d" % [amount, save_data.gold])
	save_game()

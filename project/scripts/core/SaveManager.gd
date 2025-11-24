extends Node

const SAVE_PATH = "user://savegame.save"

func save_game():
	var data = {
		"money": GameManager.money,
		"xp": GameManager.xp,
		"level": GameManager.level,
		"timestamp": Time.get_unix_time_from_system()
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		print("Game Saved")
	else:
		push_error("Failed to open save file for writing")

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		if data:
			GameManager.money = data.get("money", 0.0)
			GameManager.xp = data.get("xp", 0)
			GameManager.level = data.get("level", 1)
			_calculate_offline_earnings(data.get("timestamp", Time.get_unix_time_from_system()))
			print("Game Loaded")

func _calculate_offline_earnings(last_timestamp):
	var current_time = Time.get_unix_time_from_system()
	var diff = current_time - last_timestamp
	if diff > 0:
		print("Offline for ", diff, " seconds")
		# TODO: Calculate earnings based on buildings

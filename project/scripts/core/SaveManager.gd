extends Node

const SAVE_DIR = "user://saves/"
const SAVE_FILE_TEMPLATE = "save_slot_%02d.json"
const TEMP_SUFFIX = ".tmp"

# Current loaded slot, -1 if none
var current_slot: int = -1
var load_on_start: bool = false

# Auto-save settings
const AUTO_SAVE_INTERVAL: float = 300.0 # 5 minutes
var _auto_save_timer: float = 0.0

func _ready() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_absolute(SAVE_DIR)

func _process(delta: float) -> void:
	if current_slot != -1:
		_auto_save_timer += delta
		if _auto_save_timer >= AUTO_SAVE_INTERVAL:
			request_save()

func request_save() -> void:
	if current_slot != -1:
		save_game(current_slot)
		_auto_save_timer = 0.0
		print("Save requested and executed")

func save_exists(slot_index: int) -> bool:
	var file_name = SAVE_FILE_TEMPLATE % slot_index
	return FileAccess.file_exists(SAVE_DIR + file_name)

func get_save_info(slot_index: int) -> Dictionary:
	var file_path = SAVE_DIR + (SAVE_FILE_TEMPLATE % slot_index)
	if not FileAccess.file_exists(file_path):
		return {}
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {}
		
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK and typeof(json.data) == TYPE_DICTIONARY:
		return json.data
	return {}

func delete_save(slot_index: int) -> void:
	var file_name = SAVE_FILE_TEMPLATE % slot_index
	var file_path = SAVE_DIR + file_name
	var dir = DirAccess.open(SAVE_DIR)
	if dir and dir.file_exists(file_name):
		dir.remove(file_name)
		print("Deleted save slot ", slot_index)

func save_game(slot_index: int = 0) -> bool:
	var data = _collect_save_data()
	var file_name = SAVE_FILE_TEMPLATE % slot_index
	var file_path = SAVE_DIR + file_name
	var temp_path = file_path + TEMP_SUFFIX
	
	var file = FileAccess.open(temp_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open temp save file: " + temp_path)
		return false
		
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	
	# Safe write: Rename temp to actual
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		# Remove old file if exists
		if FileAccess.file_exists(file_path):
			dir.remove(file_name)
		dir.rename(file_name + TEMP_SUFFIX, file_name)
		print("Game saved successfully to slot ", slot_index)
		current_slot = slot_index
		return true
	else:
		push_error("Failed to access save directory for rename")
		return false

func load_game(slot_index: int = 0) -> bool:
	var file_path = SAVE_DIR + (SAVE_FILE_TEMPLATE % slot_index)
	if not FileAccess.file_exists(file_path):
		push_warning("Save file not found: " + file_path)
		return false
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open save file: " + file_path)
		return false
		
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		var data = json.data
		if typeof(data) == TYPE_DICTIONARY:
			_apply_save_data(data)
			current_slot = slot_index
			print("Game loaded from slot ", slot_index)
			return true
		else:
			push_error("Save file corrupted (not a dictionary)")
	else:
		push_error("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		
	return false

func get_save_files() -> Array:
	var saves = []
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() and file_name.begins_with("save_slot_") and file_name.ends_with(".json"):
				saves.append(file_name)
			file_name = dir.get_next()
	return saves

func _collect_save_data() -> Dictionary:
	var data = {
		"version": "0.0.1",
		"timestamp": Time.get_unix_time_from_system(),
		"game_manager": GameManager.get_save_data(),
		# GridManager needs to be accessed via MainGame or Singleton. 
		# For now, we assume GridManager is a child of MainGame and we might need a way to access it.
		# Better approach: Use a group "persist" and call get_save_data on them?
		# Or just access via MainGame if it's a singleton or accessible.
		# Since GridManager is in the scene tree, we need to find it.
	}
	
	# Find GridManager in the active scene
	var tree = get_tree()
	if tree and tree.current_scene:
		var grid_manager = tree.current_scene.find_child("GridManager", true, false)
		if grid_manager and grid_manager.has_method("get_save_data"):
			data["grid_manager"] = grid_manager.get_save_data()
			
	return data

func _apply_save_data(data: Dictionary) -> void:
	if data.has("game_manager"):
		GameManager.load_save_data(data["game_manager"])
		
	if data.has("grid_manager"):
		var tree = get_tree()
		if tree and tree.current_scene:
			var grid_manager = tree.current_scene.find_child("GridManager", true, false)
			if grid_manager and grid_manager.has_method("load_save_data"):
				grid_manager.load_save_data(data["grid_manager"])

func _calculate_offline_earnings(last_timestamp):
	var current_time = Time.get_unix_time_from_system()
	var diff = current_time - last_timestamp
	if diff > 0:
		print("Offline for ", diff, " seconds")
		# TODO: Calculate earnings based on buildings

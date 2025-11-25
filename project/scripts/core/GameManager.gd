extends Node

# GameManager: Handles global game state
signal money_changed(new_amount)
signal products_changed(current, max)
signal xp_changed(new_amount)
signal level_changed(new_level)
signal inventory_changed(new_inventory)
signal market_rolls_changed(new_rolls)
signal market_options_changed(new_options)
signal game_restarted()
signal tutorial_step_changed(step)

var tutorial_step: int = 0:
	set(value):
		tutorial_step = value
		tutorial_step_changed.emit(tutorial_step)

var money: float = 0.0:
	set(value):
		money = value
		money_changed.emit(money)

# Dictionary to store resources: {"wheat": 10, "flour": 5}
var resources: Dictionary = {
	"wheat": 0.0,
	"flour": 0.0
}

signal resources_changed(resources)

# Getter for total products (backward compatibility)
var products: float:
	get:
		var total = 0.0
		for amount in resources.values():
			total += amount
		return total
	set(_value):
		# Deprecated setter
		pass

var max_storage: float = 100.0:
	set(value):
		max_storage = value
		products_changed.emit(products, max_storage)

var xp: int = 0:
	set(value):
		xp = value
		xp_changed.emit(xp)

var level: int = 1:
	set(value):
		level = value
		level_changed.emit(level)
		SaveManager.request_save()

var inventory: Array[BuildingInstance] = []
var placing_building: BuildingInstance = null

# Market System
const MAX_MARKET_ROLLS: int = 10
const ROLL_REGEN_TIME: float = 60.0 # Seconds per roll

var market_rolls: int = 10:
	set(value):
		market_rolls = clamp(value, 0, MAX_MARKET_ROLLS)
		market_rolls_changed.emit(market_rolls)

var last_roll_regen_timestamp: float = 0.0
var current_market_options: Array[BuildingData] = []
var market_manager: MarketManager

var shipping_bin_data

# Item Database: ID -> ItemData
var item_database: Dictionary = {}

func _ready():
	print("GameManager Initialized")
	_load_item_database()
	
	shipping_bin_data = load("res://resources/data/ShippingBin.tres")
	
	# Initial capital for testing
	money = 500.0
	
	# Initialize MarketManager
	market_manager = MarketManager.new()
	add_child(market_manager)
	market_manager.load_all_buildings()
	
	last_roll_regen_timestamp = Time.get_unix_time_from_system()
	# TODO: Connect to SaveManager to load data on start

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Close request received. Saving game...")
		if SaveManager.current_slot != -1:
			SaveManager.request_save()
		# No need to call quit(), Godot does it automatically after this notification

func start_new_game() -> void:
	print("Starting new game...")
	money = 500.0
	products = 0.0
	max_storage = 100.0
	xp = 0
	level = 1
	market_rolls = 10
	last_roll_regen_timestamp = Time.get_unix_time_from_system()
	
	inventory.clear()
	game_restarted.emit()
	
	# Add Shipping Bin to inventory
	add_building_to_inventory(shipping_bin_data)
	
	current_market_options.clear()
	market_options_changed.emit(current_market_options)
	
	SaveManager.request_save()

func _process(delta: float) -> void:
	_process_market_regen()

func _process_market_regen() -> void:
	if market_rolls >= MAX_MARKET_ROLLS:
		last_roll_regen_timestamp = Time.get_unix_time_from_system()
		return
		
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_roll_regen_timestamp >= ROLL_REGEN_TIME:
		var rolls_to_add = floor((current_time - last_roll_regen_timestamp) / ROLL_REGEN_TIME)
		market_rolls += int(rolls_to_add)
		last_roll_regen_timestamp += rolls_to_add * ROLL_REGEN_TIME
		print("Regenerated ", rolls_to_add, " rolls. Total: ", market_rolls)

func try_roll_market() -> bool:
	if market_rolls > 0:
		market_rolls -= 1
		current_market_options = market_manager.generate_draft_options(3)
		market_options_changed.emit(current_market_options)
		return true
	return false

func clear_market_options() -> void:
	current_market_options = []
	market_options_changed.emit(current_market_options)

func get_time_until_next_roll() -> float:
	if market_rolls >= MAX_MARKET_ROLLS:
		return 0.0
	var current_time = Time.get_unix_time_from_system()
	return max(0.0, ROLL_REGEN_TIME - (current_time - last_roll_regen_timestamp))

func request_save() -> void:
	SaveManager.request_save()

func add_money(amount: float) -> void:
	money += amount
	print("Money added: ", amount, " | Total: ", money)
	# Don't save on every income tick, rely on auto-save

func add_xp(amount: int) -> void:
	xp += amount
	print("XP added: ", amount, " | Total: ", xp)
	# Check for level up logic here if needed
	# For now just accumulate
	request_save()

func get_total_weight() -> float:
	var total_weight = 0.0
	for id in resources:
		var amount = resources[id]
		var item_data = get_item_data(id)
		var weight = 1.0
		if item_data:
			weight = item_data.weight
		total_weight += amount * weight
	return total_weight

func add_products(amount: float) -> float:
	return add_resource("wheat", amount) # Default to wheat for legacy calls

func add_resource(id: String, amount: float) -> float:
	var item_data = get_item_data(id)
	var weight = 1.0
	if item_data:
		weight = item_data.weight
		
	var current_weight = get_total_weight()
	var space_left = max_storage - current_weight
	
	# Calculate how much we can fit: amount * weight <= space_left
	var amount_to_add = amount
	if weight > 0:
		amount_to_add = min(amount, space_left / weight)
	else:
		# If weight is 0, we can add infinite? Let's assume yes or cap by amount
		amount_to_add = amount
	
	if amount_to_add > 0:
		if not resources.has(id):
			resources[id] = 0.0
		resources[id] += amount_to_add
		products_changed.emit(get_total_weight(), max_storage)
		resources_changed.emit(resources)
	
	return amount_to_add

func consume_products(amount: float) -> float:
	# Legacy: Consume from any available resource (prioritize wheat?)
	return consume_resource("wheat", amount)

func consume_resource(id: String, amount: float) -> float:
	if not resources.has(id):
		return 0.0
		
	var available = resources[id]
	var consumed = min(amount, available)
	
	resources[id] -= consumed
	products_changed.emit(get_total_weight(), max_storage)
	resources_changed.emit(resources)
	
	return consumed

func get_resource_count(id: String) -> float:
	return resources.get(id, 0.0)

func _load_item_database() -> void:
	var path = "res://resources/data/items/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".remap")):
				var clean_name = file_name.replace(".remap", "")
				var res = load(path + clean_name)
				if res is ItemData:
					item_database[res.id] = res
					print("Loaded item: ", res.id)
			file_name = dir.get_next()
	else:
		print("Failed to open item database path: ", path)

func get_item_data(id: String) -> ItemData:
	return item_database.get(id)

func get_save_data() -> Dictionary:
	var inventory_data = []
	for item in inventory:
		if item and item.data:
			inventory_data.append({
				"path": item.data.resource_path,
				"level": item.level,
				"xp": item.xp,
				"variant": item.selected_variant_index
			})
		
	var market_option_paths = []
	for item in current_market_options:
		market_option_paths.append(item.resource_path)

	return {
		"money": money,
		"resources": resources,
		"max_storage": max_storage,
		"xp": xp,
		"level": level,
		"market_rolls": market_rolls,
		"last_roll_regen_timestamp": last_roll_regen_timestamp,
		"inventory": inventory_data,
		"current_market_options": market_option_paths,
		"tutorial_step": tutorial_step
	}

func load_save_data(data: Dictionary) -> void:
	money = data.get("money", 0.0)
	resources = data.get("resources", {"wheat": 0.0, "flour": 0.0})
	max_storage = data.get("max_storage", 100.0)
	xp = data.get("xp", 0)
	level = data.get("level", 1)
	market_rolls = data.get("market_rolls", 10)
	last_roll_regen_timestamp = data.get("last_roll_regen_timestamp", Time.get_unix_time_from_system())
	tutorial_step = data.get("tutorial_step", 0)
	
	inventory.clear()
	var inventory_data = data.get("inventory", [])
	for item_data in inventory_data:
		# Handle legacy save (string path) or new save (dict)
		if item_data is String:
			if ResourceLoader.exists(item_data):
				var res = load(item_data)
				if res is BuildingData:
					inventory.append(BuildingInstance.new(res))
		elif item_data is Dictionary:
			var path = item_data.get("path")
			if path and ResourceLoader.exists(path):
				var res = load(path)
				if res is BuildingData:
					var item_level = item_data.get("level", 1)
					var item_xp = item_data.get("xp", 0)
					var item_variant = item_data.get("variant", 0)
					inventory.append(BuildingInstance.new(res, item_level, item_xp, item_variant))
	inventory_changed.emit(inventory)
	
	current_market_options.clear()
	var market_option_paths = data.get("current_market_options", [])
	for path in market_option_paths:
		if ResourceLoader.exists(path):
			var res = load(path)
			if res is BuildingData:
				current_market_options.append(res)
	market_options_changed.emit(current_market_options)

func spend_money(amount: float) -> bool:
	if money >= amount:
		money -= amount
		request_save() # Save on purchase
		return true
	return false

func add_building_to_inventory(building) -> void:
	var instance: BuildingInstance
	if building is BuildingData:
		instance = BuildingInstance.new(building)
	elif building is BuildingInstance:
		instance = building
	else:
		push_error("Invalid building type added to inventory")
		return
		
	inventory.append(instance)
	inventory_changed.emit(inventory)
	print("Added to inventory: ", instance.data.name)
	request_save()

func remove_building_from_inventory(index: int) -> BuildingInstance:
	if index >= 0 and index < inventory.size():
		var building = inventory.pop_at(index)
		inventory_changed.emit(inventory)
		request_save()
		return building
	return null

func merge_buildings(source: BuildingInstance, target: BuildingInstance) -> bool:
	if not source or not target: return false
	if source == target: return false
	if source.data.id != target.data.id: return false
	if source.level != target.level: return false
	if source.level >= source.data.max_level: return false
	
	# Remove source
	inventory.erase(source)
	
	# Upgrade target
	target.level += 1
	target.xp = 0 # Reset XP on merge
	
	inventory_changed.emit(inventory)
	request_save()
	print("Merged buildings: %s to level %d" % [target.data.name, target.level])
	return true

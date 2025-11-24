extends Node

signal money_changed(new_amount)
signal xp_changed(new_amount)
signal level_changed(new_level)
signal inventory_changed(new_inventory)
signal market_rolls_changed(new_rolls)
signal market_options_changed(new_options)

var money: float = 0.0:
	set(value):
		money = value
		money_changed.emit(money)

var xp: int = 0:
	set(value):
		xp = value
		xp_changed.emit(xp)

var level: int = 1:
	set(value):
		level = value
		level_changed.emit(level)
		SaveManager.request_save()

var inventory: Array[BuildingData] = []
var placing_building: BuildingData = null

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

func _ready():
	print("GameManager Initialized")
	# Initial capital for testing
	money = 500.0
	
	# Initialize MarketManager
	market_manager = MarketManager.new()
	add_child(market_manager)
	market_manager.load_all_buildings()
	
	last_roll_regen_timestamp = Time.get_unix_time_from_system()
	# TODO: Connect to SaveManager to load data on start

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
 
	# Better to save on big events like level up or purchase.

func get_save_data() -> Dictionary:
	var inventory_paths = []
	for item in inventory:
		inventory_paths.append(item.resource_path)
		
	var market_option_paths = []
	for item in current_market_options:
		market_option_paths.append(item.resource_path)

	return {
		"money": money,
		"xp": xp,
		"level": level,
		"market_rolls": market_rolls,
		"last_roll_regen_timestamp": last_roll_regen_timestamp,
		"inventory": inventory_paths,
		"current_market_options": market_option_paths
	}

func load_save_data(data: Dictionary) -> void:
	money = data.get("money", 0.0)
	xp = data.get("xp", 0)
	level = data.get("level", 1)
	market_rolls = data.get("market_rolls", 10)
	last_roll_regen_timestamp = data.get("last_roll_regen_timestamp", Time.get_unix_time_from_system())
	
	inventory.clear()
	var inventory_paths = data.get("inventory", [])
	for path in inventory_paths:
		if ResourceLoader.exists(path):
			var res = load(path)
			if res is BuildingData:
				inventory.append(res)
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

func add_building_to_inventory(building: BuildingData) -> void:
	inventory.append(building)
	inventory_changed.emit(inventory)
	print("Added to inventory: ", building.name)
	request_save()

func remove_building_from_inventory(index: int) -> BuildingData:
	if index >= 0 and index < inventory.size():
		var building = inventory.pop_at(index)
		inventory_changed.emit(inventory)
		request_save()
		return building
	return null

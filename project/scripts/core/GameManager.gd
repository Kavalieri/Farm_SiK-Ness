extends Node

signal money_changed(new_amount)
signal xp_changed(new_amount)
signal level_changed(new_level)
signal inventory_changed(new_inventory)

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

var inventory: Array[BuildingData] = []
var placing_building: BuildingData = null

func add_money(amount: float) -> void:
	money += amount
	print("Money added: ", amount, " | Total: ", money)

func spend_money(amount: float) -> bool:
	if money >= amount:
		money -= amount
		return true
	return false

func add_building_to_inventory(building: BuildingData) -> void:
	inventory.append(building)
	inventory_changed.emit(inventory)
	print("Added to inventory: ", building.name)

func remove_building_from_inventory(index: int) -> BuildingData:
	if index >= 0 and index < inventory.size():
		var building = inventory.pop_at(index)
		inventory_changed.emit(inventory)
		return building
	return null

func _ready():
	print("GameManager Initialized")
	# Initial capital for testing
	money = 500.0
	# TODO: Connect to SaveManager to load data on start

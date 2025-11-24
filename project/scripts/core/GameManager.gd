extends Node

signal money_changed(new_amount)
signal xp_changed(new_amount)
signal level_changed(new_level)

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

func add_money(amount: float) -> void:
	money += amount
	print("Money added: ", amount, " | Total: ", money)

func spend_money(amount: float) -> bool:
	if money >= amount:
		money -= amount
		return true
	return false

func _ready():
	print("GameManager Initialized")
	# TODO: Connect to SaveManager to load data on start

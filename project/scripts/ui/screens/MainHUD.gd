extends Control

signal market_opened
signal inventory_opened

@onready var money_display: HBoxContainer = %MoneyDisplay
@onready var xp_display: HBoxContainer = %XPDisplay
@onready var market_button: Button = %MarketButton
@onready var inventory_button: Button = %InventoryButton

func _ready() -> void:
	# Connect to GameManager signals
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.xp_changed.connect(_on_xp_changed)
	
	# Connect buttons
	market_button.pressed.connect(_on_market_button_pressed)
	inventory_button.pressed.connect(_on_inventory_button_pressed)
	
	# Initialize values
	_on_money_changed(GameManager.money)
	_on_xp_changed(GameManager.xp)

func _on_money_changed(new_amount: float) -> void:
	money_display.update_value(new_amount)

func _on_xp_changed(new_amount: int) -> void:
	xp_display.update_value(new_amount)

func _on_market_button_pressed() -> void:
	market_opened.emit()

func _on_inventory_button_pressed() -> void:
	inventory_opened.emit()


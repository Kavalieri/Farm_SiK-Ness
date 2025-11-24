extends Control

signal market_opened
signal inventory_opened
signal settings_opened

@onready var money_display: HBoxContainer = %MoneyDisplay
@onready var xp_display: HBoxContainer = %XPDisplay
@onready var products_display: HBoxContainer = %ProductsDisplay
@onready var market_button: Button = %MarketButton
@onready var inventory_button: Button = %InventoryButton
@onready var settings_button: Button = %SettingsButton

func _ready() -> void:
	# Connect to GameManager signals
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.xp_changed.connect(_on_xp_changed)
	GameManager.products_changed.connect(_on_products_changed)
	
	# Connect buttons
	market_button.pressed.connect(_on_market_button_pressed)
	inventory_button.pressed.connect(_on_inventory_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	
	GameManager.market_rolls_changed.connect(_on_market_rolls_changed)
	GameManager.inventory_changed.connect(_on_inventory_changed)
	
	# Initialize values
	_on_money_changed(GameManager.money)
	_on_xp_changed(GameManager.xp)
	_on_products_changed(GameManager.products, GameManager.max_storage)
	_on_market_rolls_changed(GameManager.market_rolls)
	_on_inventory_changed(GameManager.inventory)

func _process(_delta: float) -> void:
	_update_market_button_timer()

func _on_money_changed(new_amount: float) -> void:
	money_display.update_value(new_amount)

func _on_xp_changed(new_amount: int) -> void:
	xp_display.update_value(new_amount)

func _on_products_changed(current: float, max_amount: float) -> void:
	products_display.update_label("PROD %d/%d" % [int(current), int(max_amount)])

func _on_market_button_pressed() -> void:
	market_opened.emit()

func _on_market_rolls_changed(new_rolls: int) -> void:
	_update_market_button_text(new_rolls)

var _inventory_tween: Tween

func _on_inventory_changed(inventory: Array[BuildingData]) -> void:
	if _inventory_tween:
		_inventory_tween.kill()
		
	if inventory.size() > 0:
		# Highlight inventory button
		_inventory_tween = create_tween().set_loops()
		_inventory_tween.tween_property(inventory_button, "modulate", Color(1.5, 1.5, 1.5), 0.5)
		_inventory_tween.tween_property(inventory_button, "modulate", Color(1.0, 1.0, 1.0), 0.5)
	else:
		inventory_button.modulate = Color(1, 1, 1)

func _update_market_button_text(rolls: int) -> void:
	market_button.text = "MARKET (%d)" % rolls

func _update_market_button_timer() -> void:
	if GameManager.market_rolls < GameManager.MAX_MARKET_ROLLS:
		var time_left = GameManager.get_time_until_next_roll()
		market_button.text = "MARKET (%d)\n%ds" % [GameManager.market_rolls, int(time_left)]
	else:
		# Only update if text is different to avoid constant redraws/layout calcs if not needed, 
		# though text assignment is cheap.
		if "s" in market_button.text:
			market_button.text = "MARKET (%d)" % GameManager.market_rolls

func _on_inventory_button_pressed() -> void:
	inventory_opened.emit()

func _on_settings_button_pressed() -> void:
	settings_opened.emit()


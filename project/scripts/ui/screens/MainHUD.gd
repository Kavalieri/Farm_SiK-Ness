extends Control

@onready var money_display: HBoxContainer = %MoneyDisplay
@onready var xp_display: HBoxContainer = %XPDisplay
@onready var market_button: Button = %MarketButton

func _ready() -> void:
	# Connect to GameManager signals
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.xp_changed.connect(_on_xp_changed)
	
	# Initialize values
	_on_money_changed(GameManager.money)
	_on_xp_changed(GameManager.xp)

func _on_money_changed(new_amount: float) -> void:
	money_display.update_value(new_amount)

func _on_xp_changed(new_amount: int) -> void:
	xp_display.update_value(new_amount)


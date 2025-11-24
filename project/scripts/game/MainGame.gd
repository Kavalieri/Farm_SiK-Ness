class_name MainGame
extends Node2D

@onready var main_hud: Control = $CanvasLayer/MainHUD
@onready var market_modal: MarketModal = $CanvasLayer/MarketModal

func _ready() -> void:
	main_hud.market_opened.connect(_on_market_opened)

func _on_market_opened() -> void:
	market_modal.open()

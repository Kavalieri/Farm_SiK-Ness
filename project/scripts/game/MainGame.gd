class_name MainGame
extends Node2D

@onready var main_hud: Control = $CanvasLayer/MainHUD
@onready var market_modal: MarketModal = $CanvasLayer/MarketModal
@onready var inventory_panel: InventoryPanel = $CanvasLayer/InventoryPanel

func _ready() -> void:
	main_hud.market_opened.connect(_on_market_opened)
	main_hud.inventory_opened.connect(_on_inventory_opened)

func _on_market_opened() -> void:
	market_modal.open()
	inventory_panel.close()

func _on_inventory_opened() -> void:
	inventory_panel.open()
	market_modal.close()

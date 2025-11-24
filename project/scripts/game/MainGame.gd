class_name MainGame
extends Node2D

@onready var main_hud: Control = $CanvasLayer/MainHUD
@onready var market_modal: MarketModal = $CanvasLayer/MarketModal
@onready var inventory_panel: InventoryPanel = $CanvasLayer/InventoryPanel
@onready var settings_modal: Control = $CanvasLayer/SettingsModal
@onready var grid_manager: GridManager = $GridManager
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	main_hud.market_opened.connect(_on_market_opened)
	main_hud.inventory_opened.connect(_on_inventory_opened)
	main_hud.settings_opened.connect(_on_settings_opened)
	
	# Center camera on grid
	var grid_center = (Vector2(grid_manager.grid_size) * Vector2(grid_manager.cell_size)) / 2.0
	camera.position = grid_center
	
	# Auto-load if requested
	if SaveManager.load_on_start and SaveManager.current_slot != -1:
		print("Auto-loading slot ", SaveManager.current_slot)
		# Defer load to ensure all nodes are ready
		call_deferred("_load_game")

func _load_game() -> void:
	SaveManager.load_game(SaveManager.current_slot)

func _on_market_opened() -> void:
	market_modal.open()
	inventory_panel.close()
	settings_modal.close()

func _on_inventory_opened() -> void:
	inventory_panel.open()
	market_modal.close()
	settings_modal.close()

func _on_settings_opened() -> void:
	settings_modal.open()
	market_modal.close()
	inventory_panel.close()

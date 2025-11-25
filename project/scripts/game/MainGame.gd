class_name MainGame
extends Node2D

@onready var main_hud: Control = $CanvasLayer/MainHUD
@onready var market_modal: MarketModal = $CanvasLayer/MarketModal
@onready var inventory_panel: InventoryPanel = $CanvasLayer/InventoryPanel
@onready var building_inspector: BuildingInspector = $CanvasLayer/BuildingInspector
@onready var settings_modal: Control = $CanvasLayer/SettingsModal
@onready var grid_manager: GridManager = $GridManager
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	main_hud.market_opened.connect(_on_market_opened)
	main_hud.inventory_opened.connect(_on_inventory_opened)
	main_hud.settings_opened.connect(_on_settings_opened)
	
	building_inspector.return_requested.connect(_on_return_requested)
	
	grid_manager.building_selected.connect(_on_building_selected)
	grid_manager.building_placed.connect(_on_building_placed)
	
	# Center camera on grid
	call_deferred("_center_camera")
	
	# Auto-load if requested
	if SaveManager.load_on_start and SaveManager.current_slot != -1:
		print("Auto-loading slot ", SaveManager.current_slot)
		# Defer load to ensure all nodes are ready
		call_deferred("_load_game")
	else:
		# Start new game
		GameManager.start_new_game()

func _center_camera() -> void:
	var grid_size_px = Vector2(grid_manager.grid_size) * Vector2(grid_manager.cell_size)
	var grid_center = grid_manager.position + (grid_size_px / 2.0)
	camera.position = grid_center
	print("Camera centered at: ", camera.position, " for grid size: ", grid_size_px)

func _load_game() -> void:
	SaveManager.load_game(SaveManager.current_slot)

func _on_market_opened() -> void:
	if GameManager.tutorial_step == 2:
		GameManager.tutorial_step = 3
		_update_tutorial_state()
		
	market_modal.open()
	inventory_panel.close()
	settings_modal.close()

func _on_inventory_opened() -> void:
	if GameManager.tutorial_step == 0:
		GameManager.tutorial_step = 1
		_update_tutorial_state()
		
	inventory_panel.open()
	market_modal.close()
	settings_modal.close()

func _on_settings_opened() -> void:
	settings_modal.open()
	market_modal.close()
	inventory_panel.close()
	building_inspector.visible = false

func _on_return_requested(building_entity: Node2D) -> void:
	if building_entity and building_entity.get("data"):
		# Create instance with current state
		var level = building_entity.get("level") if building_entity.get("level") else 1
		var xp = building_entity.get("xp") if building_entity.get("xp") else 0
		var variant = building_entity.get("selected_variant_index") if building_entity.get("selected_variant_index") else 0
		
		var instance = BuildingInstance.new(building_entity.data, level, xp, variant)
		
		# Add back to inventory
		GameManager.add_building_to_inventory(instance)
		
		# Remove from grid
		grid_manager.remove_building(building_entity)
		
		# Close inspector
		building_inspector.visible = false

func _on_building_selected(building: Node2D) -> void:
	if building:
		# Assuming building has 'data' property. 
		# ShippingBin might not have it directly if it's not a BuildingEntity, 
		# but we made it inherit BuildingEntity or at least have setup.
		# Let's check if it has 'data'.
		var data = building.get("data")
		if data:
			var level = building.get("level") if building.get("level") else 1
			building_inspector.setup(data, level, building)
			building_inspector.visible = true
			
			# If it's a BuildingEntity, we can get dynamic stats
			if building is BuildingEntity:
				building_inspector.update_dynamic_stats(building.current_production, [])
		else:
			# Special case for ShippingBin if it doesn't have data property set correctly
			# But we should ensure it does.
			pass
	else:
		building_inspector.visible = false

func _update_tutorial_state() -> void:
	var step = GameManager.tutorial_step
	
	match step:
		0: # Start: Force place Shipping Bin
			main_hud.set_market_disabled(true)
			main_hud.set_settings_disabled(true)
			main_hud.highlight_inventory(true)
			# Optional: Show a welcome message here if we had a dialog system
		1: # Inventory opened, waiting for placement
			main_hud.highlight_inventory(false)
			# Still block market/settings
			main_hud.set_market_disabled(true)
			main_hud.set_settings_disabled(true)
		2: # Shipping Bin placed: Unlock Market
			main_hud.set_market_disabled(false)
			main_hud.set_settings_disabled(false)
			main_hud.highlight_market(true)
		3: # Market opened: Tutorial complete
			main_hud.highlight_market(false)
			main_hud.set_market_disabled(false)
			main_hud.set_settings_disabled(false)

func _on_building_placed(building_data: Resource, _cell: Vector2i) -> void:
	if GameManager.tutorial_step == 1:
		if building_data.id == "shipping_bin":
			GameManager.tutorial_step = 2
			_update_tutorial_state()
			# Show success message?

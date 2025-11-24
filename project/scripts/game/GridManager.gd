class_name GridManager
extends Node2D

signal building_placed(building_data: Resource, grid_pos: Vector2i)

@export_group("Grid Settings")
@export var cell_size: Vector2i = Vector2i(64, 64)
@export var grid_size: Vector2i = Vector2i(10, 10)

# DEBUG: Temporary for testing
@export var debug_building_data: BuildingData
@export var debug_building_scene: PackedScene

# Dictionary to store grid state. Key: Vector2i (coords), Value: BuildingEntity (or null)
var _grid_state: Dictionary = {}
var _click_start_pos: Vector2

var ghost_building: Node2D
var ghost_scene = preload("res://scenes/game/GhostBuilding.tscn")

@onready var ground_layer: TileMapLayer = %GroundLayer
@onready var buildings_container: Node2D = %BuildingsContainer
@onready var ghost_container: Node2D = %GhostContainer

func _ready() -> void:
	print("GridManager Ready")
	_initialize_grid()
	queue_redraw() # Force draw grid lines
	
	# Load debug resources if not set in inspector
	if not debug_building_data:
		debug_building_data = load("res://resources/data/buildings/silo.tres")
	if not debug_building_scene:
		debug_building_scene = load("res://scenes/game/BuildingEntity.tscn")

func _process(_delta: float) -> void:
	_update_ghost()

func _update_ghost() -> void:
	if not GameManager.placing_building:
		if ghost_building:
			ghost_building.queue_free()
			ghost_building = null
		return

	if not ghost_building:
		ghost_building = ghost_scene.instantiate()
		ghost_container.add_child(ghost_building)
		ghost_building.setup(GameManager.placing_building, cell_size)
	elif ghost_building.data != GameManager.placing_building:
		# Update existing ghost with new data
		ghost_building.setup(GameManager.placing_building, cell_size)
	
	var mouse_pos = get_global_mouse_position()
	var grid_pos = world_to_grid(mouse_pos)
	ghost_building.position = grid_to_world(grid_pos)
	
	var is_valid = can_place_building(grid_pos, GameManager.placing_building.shape_pattern)
	ghost_building.set_valid(is_valid)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_click_start_pos = event.position
			else:
				# On Release
				if not GameManager.placing_building:
					return
				
				# Check if it was a drag (pan) or a click
				if event.position.distance_to(_click_start_pos) > 10.0:
					return # It was a drag, ignore placement
					
				var grid_pos = world_to_grid(get_global_mouse_position())
				
				if can_place_building(grid_pos, GameManager.placing_building.shape_pattern):
					place_building(debug_building_scene, grid_pos, GameManager.placing_building)
					
					# Remove from inventory (find first instance)
					var idx = GameManager.inventory.find(GameManager.placing_building)
					if idx != -1:
						GameManager.remove_building_from_inventory(idx)
					
					# Deselect after placement
					GameManager.placing_building = null
		
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Cancel placement
			if GameManager.placing_building:
				GameManager.placing_building = null
				print("Placement cancelled")

func _initialize_grid() -> void:
	# Initialize empty grid or load from save
	pass

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(world_pos / Vector2(cell_size))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos * cell_size)

func is_valid_grid_pos(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y

func can_place_building(grid_pos: Vector2i, shape_pattern: Array) -> bool:
	for offset in shape_pattern:
		var check_pos = grid_pos + offset
		if not is_valid_grid_pos(check_pos):
			return false
		if _grid_state.has(check_pos):
			return false
	return true

func place_building(scene: PackedScene, grid_pos: Vector2i, data: BuildingData) -> void:
	var building = scene.instantiate()
	buildings_container.add_child(building)
	building.setup(data, cell_size)
	building.position = grid_to_world(grid_pos)
	
	# Update grid state
	for offset in data.shape_pattern:
		var pos = grid_pos + offset
		_grid_state[pos] = building
	
	building_placed.emit(data, grid_pos)
	# GameManager.request_save() # Removed to avoid save loop during load and double save on placement

func _draw() -> void:
	# Draw grid lines for debugging
	var color = Color(1, 1, 1, 0.5)
	for x in range(grid_size.x + 1):
		var start = Vector2(x * cell_size.x, 0)
		var end = Vector2(x * cell_size.x, grid_size.y * cell_size.y)
		draw_line(start, end, color)
	
	for y in range(grid_size.y + 1):
		var start = Vector2(0, y * cell_size.y)
		var end = Vector2(grid_size.x * cell_size.x, y * cell_size.y)
		draw_line(start, end, color)

func get_save_data() -> Array:
	var buildings_data = []
	for child in buildings_container.get_children():
		if child is BuildingEntity and child.data:
			var grid_pos = world_to_grid(child.position)
			buildings_data.append({
				"path": child.data.resource_path,
				"grid_x": grid_pos.x,
				"grid_y": grid_pos.y
			})
	return buildings_data

func load_save_data(data: Array) -> void:
	# Clear existing buildings
	for child in buildings_container.get_children():
		child.queue_free()
	_grid_state.clear()
	
	# Load new buildings
	for entry in data:
		var path = entry.get("path")
		var grid_x = entry.get("grid_x")
		var grid_y = entry.get("grid_y")
		
		if path and grid_x != null and grid_y != null:
			if ResourceLoader.exists(path):
				var res = load(path)
				if res is BuildingData:
					var grid_pos = Vector2i(grid_x, grid_y)
					# We use debug_building_scene as the template for now, 
					# ideally this should be a constant or configurable scene
					place_building(debug_building_scene, grid_pos, res)

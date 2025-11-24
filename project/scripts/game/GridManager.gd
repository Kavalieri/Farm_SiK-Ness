class_name GridManager
extends Node2D

signal building_placed(building_data: Resource, grid_pos: Vector2i)

@export_group("Grid Settings")
@export var cell_size: Vector2i = Vector2i(64, 64)
@export var grid_size: Vector2i = Vector2i(20, 20)

# DEBUG: Temporary for testing
@export var debug_building_data: BuildingData
@export var debug_building_scene: PackedScene

# Dictionary to store grid state. Key: Vector2i (coords), Value: BuildingEntity (or null)
var _grid_state: Dictionary = {}

@onready var ground_layer: TileMapLayer = %GroundLayer
@onready var buildings_container: Node2D = %BuildingsContainer
@onready var ghost_container: Node2D = %GhostContainer

func _ready() -> void:
	_initialize_grid()
	queue_redraw() # Force draw grid lines
	
	# Load debug resources if not set in inspector
	if not debug_building_data:
		debug_building_data = load("res://resources/data/buildings/test_silo.tres")
	if not debug_building_scene:
		debug_building_scene = load("res://scenes/game/BuildingEntity.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Input received (Unhandled)")
		if not debug_building_data:
			push_error("Debug building data is missing!")
			return
			
		var grid_pos = world_to_grid(get_global_mouse_position())
		print("Click at grid: ", grid_pos)
		
		if can_place_building(grid_pos, debug_building_data.shape_pattern):
			print("Attempting to place building...")
			place_building(debug_building_scene, grid_pos, debug_building_data)
			print("Placed building at: ", grid_pos)
		else:
			print("Cannot place building at: ", grid_pos)

func _initialize_grid() -> void:
	# Initialize empty grid or load from save
	pass

func _draw() -> void:
	# Draw grid lines for debugging
	var color = Color(1, 1, 1, 0.2)
	for x in range(grid_size.x + 1):
		var start = Vector2(x * cell_size.x, 0)
		var end = Vector2(x * cell_size.x, grid_size.y * cell_size.y)
		draw_line(start, end, color)
	
	for y in range(grid_size.y + 1):
		var start = Vector2(0, y * cell_size.y)
		var end = Vector2(grid_size.x * cell_size.x, y * cell_size.y)
		draw_line(start, end, color)

## Converts world position (pixels) to grid coordinates
func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(world_pos / Vector2(cell_size))

## Converts grid coordinates to world position (Top-Left of cell)
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos * cell_size)

## Checks if a specific cell is within bounds and empty
func is_cell_valid(grid_pos: Vector2i) -> bool:
	if grid_pos.x < 0 or grid_pos.x >= grid_size.x:
		return false
	if grid_pos.y < 0 or grid_pos.y >= grid_size.y:
		return false
	return not _grid_state.has(grid_pos)

## Checks if a building shape can fit at the target position
func can_place_building(grid_pos: Vector2i, shape: Array[Vector2i]) -> bool:
	for offset in shape:
		var target_pos = grid_pos + offset
		if not is_cell_valid(target_pos):
			return false
	return true

## Places a building on the grid
func place_building(
	building_scene: PackedScene,
	grid_pos: Vector2i,
	building_data: BuildingData
) -> bool:
	var shape = building_data.shape_pattern
	if not can_place_building(grid_pos, shape):
		return false
		
	var building_instance = building_scene.instantiate()
	buildings_container.add_child(building_instance)
	
	# Setup building visual
	if building_instance.has_method("setup"):
		building_instance.setup(building_data, cell_size)
	
	building_instance.global_position = grid_to_world(grid_pos)
	
	# Mark cells as occupied
	for offset in shape:
		var target_pos = grid_pos + offset
		_grid_state[target_pos] = building_instance
		
	building_placed.emit(building_data, grid_pos)
	return true

class_name GridManager
extends Node2D

signal building_placed(building_data: Resource, grid_pos: Vector2i)

@export_group("Grid Settings")
@export var cell_size: Vector2i = Vector2i(64, 64)
@export var grid_size: Vector2i = Vector2i(20, 20)

# Dictionary to store grid state. Key: Vector2i (coords), Value: BuildingEntity (or null)
var _grid_state: Dictionary = {}

@onready var ground_layer: TileMapLayer = %GroundLayer
@onready var buildings_container: Node2D = %BuildingsContainer
@onready var ghost_container: Node2D = %GhostContainer

func _ready() -> void:
	_initialize_grid()

func _initialize_grid() -> void:
	# Initialize empty grid or load from save
	pass

## Converts world position (pixels) to grid coordinates
func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(world_pos / Vector2(cell_size))

## Converts grid coordinates to world position (centered in cell)
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos * cell_size) + Vector2(cell_size) / 2.0

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
	shape: Array[Vector2i]
) -> bool:
	if not can_place_building(grid_pos, shape):
		return false
		
	var building_instance = building_scene.instantiate()
	buildings_container.add_child(building_instance)
	building_instance.global_position = grid_to_world(grid_pos)
	
	# Mark cells as occupied
	for offset in shape:
		var target_pos = grid_pos + offset
		_grid_state[target_pos] = building_instance
		
	building_placed.emit(null, grid_pos) # TODO: Pass actual data
	return true

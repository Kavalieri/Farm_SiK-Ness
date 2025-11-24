class_name GhostBuilding
extends Node2D

var data: BuildingData
var shape_pattern: Array[Vector2i] = [Vector2i(0,0)]
var cell_size: Vector2i = Vector2i(64, 64)

@onready var sprite: Sprite2D = $Sprite2D

func setup(building_data: BuildingData, grid_cell_size: Vector2i) -> void:
	data = building_data
	shape_pattern = data.shape_pattern
	cell_size = grid_cell_size
	
	# Hide sprite as we draw the shape manually
	if sprite:
		sprite.visible = false
	
	queue_redraw()

func _draw() -> void:
	for cell in shape_pattern:
		var rect = Rect2(Vector2(cell) * Vector2(cell_size), Vector2(cell_size))
		draw_rect(rect, Color(1, 1, 1, 0.5), true) # Filled
		draw_rect(rect, Color(1, 1, 1, 0.8), false, 2.0) # Border

func set_valid(is_valid: bool) -> void:
	if is_valid:
		modulate = Color(0.5, 1.0, 0.5, 0.6) # Green transparent
	else:
		modulate = Color(1.0, 0.5, 0.5, 0.6) # Red transparent

class_name GhostBuilding
extends Node2D

var data: BuildingData
var shape_pattern: Array[Vector2i] = [Vector2i(0,0)]
var cell_size: Vector2i = Vector2i(64, 64)

@onready var sprite: Sprite2D = %Sprite2D

func setup(building_data: BuildingData, grid_cell_size: Vector2i) -> void:
	data = building_data
	shape_pattern = data.shape_pattern
	cell_size = grid_cell_size
	
	# Clear previous background tiles
	for child in get_children():
		if child != sprite and child.name != "InvalidIndicator":
			child.queue_free()
	
	if sprite:
		sprite.visible = true
		sprite.texture = data.texture
		
		# Calculate bounds (Same logic as BuildingEntity)
		var min_x = 0
		var max_x = 0
		var min_y = 0
		var max_y = 0
		
		if not data.shape_pattern.is_empty():
			min_x = data.shape_pattern[0].x
			max_x = data.shape_pattern[0].x
			min_y = data.shape_pattern[0].y
			max_y = data.shape_pattern[0].y
			
			for pos in data.shape_pattern:
				min_x = min(min_x, pos.x)
				max_x = max(max_x, pos.x)
				min_y = min(min_y, pos.y)
				max_y = max(max_y, pos.y)
		
		var width_cells = (max_x - min_x) + 1
		var height_cells = (max_y - min_y) + 1
		
		var target_width = width_cells * cell_size.x
		var target_height = height_cells * cell_size.y
		
		# Draw background tiles
		var tile_texture = load("res://assets/tiles/1x1-tile.png")
		if tile_texture:
			for pos in data.shape_pattern:
				var bg_sprite = Sprite2D.new()
				bg_sprite.texture = tile_texture
				add_child(bg_sprite)
				move_child(bg_sprite, 0)
				
				var tile_size = tile_texture.get_size()
				bg_sprite.scale = Vector2(
					float(cell_size.x) / tile_size.x,
					float(cell_size.y) / tile_size.y
				)
				
				bg_sprite.position = Vector2(
					pos.x * cell_size.x + cell_size.x / 2.0,
					pos.y * cell_size.y + cell_size.y / 2.0
				)
		
		# Scale and Position Sprite (Keep Aspect Centered)
		var texture_size = data.texture.get_size()
		var scale_x = target_width / texture_size.x
		var scale_y = target_height / texture_size.y
		var final_scale = min(scale_x, scale_y)
		
		sprite.scale = Vector2(final_scale, final_scale)
		
		var total_width = width_cells * cell_size.x
		var total_height = height_cells * cell_size.y
		
		var sprite_pixel_width = texture_size.x * final_scale
		var sprite_pixel_height = texture_size.y * final_scale
		
		var offset_x = (total_width - sprite_pixel_width) / 2.0
		var offset_y = (total_height - sprite_pixel_height) / 2.0
		
		sprite.position = Vector2(
			min_x * cell_size.x + offset_x,
			min_y * cell_size.y + offset_y
		)
	
	queue_redraw()

func _draw() -> void:
	# Draw a thick border around each cell to make it stand out against the background
	for cell in shape_pattern:
		var rect = Rect2(Vector2(cell) * Vector2(cell_size), Vector2(cell_size))
		# Draw dark border for contrast
		draw_rect(rect, Color(0, 0, 0, 0.8), false, 4.0)

func set_valid(is_valid: bool) -> void:
	if is_valid:
		# Bright Green, high opacity
		modulate = Color(0.6, 1.0, 0.6, 0.9)
	else:
		# Bright Red, high opacity
		modulate = Color(1.0, 0.4, 0.4, 0.9)

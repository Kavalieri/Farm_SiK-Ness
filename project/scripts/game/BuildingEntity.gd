class_name BuildingEntity
extends Node2D

var data: BuildingData

@onready var sprite_2d: Sprite2D = %Sprite2D

func setup(building_data: BuildingData, cell_size: Vector2i) -> void:
	data = building_data
	
	if data.texture:
		sprite_2d.texture = data.texture
		
		# Calculate shape bounds to determine size
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
		
		var texture_size = data.texture.get_size()
		
		# Scale to fit the target size
		sprite_2d.scale = Vector2(
			target_width / texture_size.x,
			target_height / texture_size.y
		)

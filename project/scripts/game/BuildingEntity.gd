class_name BuildingEntity
extends Node2D

const OUTLINE_SHADER = preload("res://resources/shaders/outline.gdshader")

var data: BuildingData

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var production_timer: Timer = %ProductionTimer

func setup(building_data: BuildingData, cell_size: Vector2i) -> void:
	data = building_data
	
	# Setup production
	if data.base_production > 0:
		production_timer.wait_time = 1.0 # Default 1 second for now
		production_timer.timeout.connect(_on_production_timer_timeout)
		production_timer.start()
	
	if data.texture:
		sprite_2d.texture = data.texture
		
		# Apply outline shader
		var mat = ShaderMaterial.new()
		mat.shader = OUTLINE_SHADER
		mat.set_shader_parameter("line_color", Color(0.1, 0.1, 0.1, 1.0))
		mat.set_shader_parameter("line_thickness", 1.0)
		sprite_2d.material = mat
		
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
		
		# Draw background tiles for each cell in the shape
		var tile_texture = load("res://assets/tiles/1x1-tile.png")
		if tile_texture:
			for pos in data.shape_pattern:
				var bg_sprite = Sprite2D.new()
				bg_sprite.texture = tile_texture
				add_child(bg_sprite)
				move_child(bg_sprite, 0) # Ensure it's behind the main sprite
				
				# Scale tile to fit cell_size
				var tile_size = tile_texture.get_size()
				bg_sprite.scale = Vector2(
					float(cell_size.x) / tile_size.x,
					float(cell_size.y) / tile_size.y
				)
				
				# Position relative to (0,0) of the entity
				# The entity is placed at grid_to_world(grid_pos), which is the top-left of the bounding box?
				# No, grid_to_world usually returns top-left of the cell.
				# BuildingEntity is placed at the anchor position (usually 0,0 of the shape).
				# We need to adjust for the shape pattern.
				
				bg_sprite.position = Vector2(
					pos.x * cell_size.x + cell_size.x / 2.0,
					pos.y * cell_size.y + cell_size.y / 2.0
				)

		var texture_size = data.texture.get_size()
		
		# Scale to fit the target size while maintaining aspect ratio
		var scale_x = target_width / texture_size.x
		var scale_y = target_height / texture_size.y
		var final_scale = min(scale_x, scale_y)
		
		sprite_2d.scale = Vector2(final_scale, final_scale)
		
		# Center the sprite within the bounds
		var total_width = width_cells * cell_size.x
		var total_height = height_cells * cell_size.y
		
		# Calculate center of the bounding box defined by shape_pattern
		var center_x = (min_x * cell_size.x) + (total_width / 2.0)
		var center_y = (min_y * cell_size.y) + (total_height / 2.0)
		
		if sprite_2d.centered:
			sprite_2d.position = Vector2(center_x, center_y)
		else:
			# If top-left, we need to calculate the offset to center it
			var sprite_pixel_width = texture_size.x * final_scale
			var sprite_pixel_height = texture_size.y * final_scale
			
			var offset_x = (total_width - sprite_pixel_width) / 2.0
			var offset_y = (total_height - sprite_pixel_height) / 2.0
			
			sprite_2d.position = Vector2(
				min_x * cell_size.x + offset_x,
				min_y * cell_size.y + offset_y
			)

func _on_production_timer_timeout() -> void:
	if data:
		GameManager.add_money(data.base_production)
		# TODO: Add visual feedback (floating text)

class_name BuildingEntity
extends Node2D

const OUTLINE_SHADER = preload("res://resources/shaders/outline.gdshader")
const FLOATING_TEXT_SCENE = preload("res://scenes/ui/effects/FloatingText.tscn")

var data: BuildingData
var current_production: float = 0.0
var level: int = 1

var selected_variant_index: int = 0

# Synergy Modifiers
var synergy_production_mult: float = 0.0 # Additive multiplier (e.g. 0.5 = +50%)
var synergy_speed_mult: float = 0.0 # Additive speed multiplier (e.g. 0.2 = +20% speed -> -20% interval?)
# Actually, speed usually means 1/interval. 
# If speed +20%, then new_speed = base_speed * 1.2.
# new_interval = 1 / new_speed = 1 / ( (1/base_interval) * 1.2 ) = base_interval / 1.2.
# Let's stick to "Interval Reduction" for simplicity? Or "Speed Boost"?
# "Speed Boost" is better.

var product_sprite: Sprite2D
var _cell_size: Vector2i = Vector2i(64, 64)

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var production_timer: Timer = %ProductionTimer
@onready var progress_bar: ProgressBar = %ProgressBar

func _process(_delta: float) -> void:
	if production_timer and not production_timer.is_stopped() and progress_bar and progress_bar.visible:
		var time_left = production_timer.time_left
		var wait_time = production_timer.wait_time
		if wait_time > 0:
			progress_bar.value = (1.0 - (time_left / wait_time)) * 100.0

func setup(building_data: BuildingData, cell_size: Vector2i) -> void:
	data = building_data
	_cell_size = cell_size
	
	# Create product sprite if needed
	if not product_sprite:
		product_sprite = Sprite2D.new()
		add_child(product_sprite)
		product_sprite.position = Vector2(cell_size.x * 0.5, cell_size.y * 0.5)
		product_sprite.scale = Vector2(0.5, 0.5)
		product_sprite.z_index = 1
	
	_update_production_stats()
	
	# Setup production based on type
	var should_show_progress = false
	
	if data.type == BuildingData.BuildingType.PRODUCER or data.type == BuildingData.BuildingType.PROCESSOR:
		var interval = data.production_interval if "production_interval" in data else 1.0
		
		# Check for variant override
		if not data.production_variants.is_empty() and selected_variant_index < data.production_variants.size():
			var variant = data.production_variants[selected_variant_index]
			if variant.has("interval"):
				interval = variant.interval
		
		production_timer.wait_time = interval
		if not production_timer.timeout.is_connected(_on_production_timer_timeout):
			production_timer.timeout.connect(_on_production_timer_timeout)
		production_timer.start()
		should_show_progress = true
	
	progress_bar.visible = should_show_progress
	
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

func update_synergies(neighbors: Array) -> void:
	if not data: return
	
	synergy_production_mult = 0.0
	synergy_speed_mult = 0.0
	
	for neighbor in neighbors:
		if not neighbor is BuildingEntity: continue
		if not neighbor.data: continue
		
		for tag in neighbor.data.tags:
			# Check for exact tag match (default production boost)
			if data.synergy_rules.has(tag):
				synergy_production_mult += data.synergy_rules[tag]
			
			# Check for specific effects (tag:effect)
			# We iterate keys because we can't guess the key
			for rule_key in data.synergy_rules.keys():
				if rule_key.begins_with(tag + ":"):
					var parts = rule_key.split(":")
					if parts.size() == 2:
						var effect = parts[1]
						var value = data.synergy_rules[rule_key]
						
						match effect:
							"speed":
								synergy_speed_mult += value
							"value", "production":
								synergy_production_mult += value
	
	_update_production_stats()

func _on_production_timer_timeout() -> void:
	var resource_id = data.produced_resource_id if "produced_resource_id" in data else "wheat"
	
	# Check for variant override
	if not data.production_variants.is_empty() and selected_variant_index < data.production_variants.size():
		var variant = data.production_variants[selected_variant_index]
		if variant.has("resource_id"):
			resource_id = variant.resource_id
	
	var added_amount = 0.0
	
	# Check tags for production type (Legacy check, might not be needed if resource_id is correct)
	if "crop" in data.tags:
		added_amount = GameManager.add_resource(resource_id, current_production)
	else:
		# Default to products unless specified otherwise
		added_amount = GameManager.add_resource(resource_id, current_production)
		
	if added_amount > 0:
		_spawn_floating_text("+%.0f" % added_amount, Color.WHITE)

func _spawn_floating_text(text: String, color: Color) -> void:
	var floating_text = FLOATING_TEXT_SCENE.instantiate()
	add_child(floating_text)
	floating_text.position = Vector2(_cell_size.x * 0.5, _cell_size.y * 0.5)
	floating_text.setup(text, color)

func upgrade() -> void:
	if level < data.max_level:
		level += 1
		_update_production_stats()
		GameManager.add_xp(20 * level)
		# TODO: Play upgrade effect

func _update_production_stats() -> void:
	if not data: return
	
	# 1. Calculate Base Production (Level + Variant)
	var base_prod = data.get_production_at_level(level)
	var base_interval = data.production_interval if "production_interval" in data else 1.0
	
	# Apply variant overrides
	if not data.production_variants.is_empty() and selected_variant_index < data.production_variants.size():
		var variant = data.production_variants[selected_variant_index]
		if variant.has("production"):
			# Variant production is treated as base override or multiplier?
			# Based on previous logic: current_production = variant.production * growth
			# Let's assume variant.production IS the base for that variant at level 1
			base_prod = variant.production * (1.0 + (data.production_growth * (level - 1)))
		if variant.has("interval"):
			base_interval = variant.interval

	# 2. Apply Synergies
	# Production: Base * (1 + SynergyMult)
	current_production = base_prod * (1.0 + synergy_production_mult)
	
	# Speed: Interval / (1 + SynergySpeed)
	# Example: +100% speed (mult=1.0) -> Interval / 2.0
	var final_interval = base_interval / (1.0 + synergy_speed_mult)
	
	# 3. Apply to Timer
	if production_timer:
		# Only restart if significant change or stopped? 
		# Changing wait_time doesn't affect current cycle unless we restart or it's stopped.
		# But restarting resets progress. We should adjust time_left if possible, or just set wait_time for next cycle.
		production_timer.wait_time = final_interval
		if production_timer.is_stopped() and base_prod > 0:
			production_timer.start()
			
	# 4. Update Visuals (Product Icon)
	if product_sprite and not data.production_variants.is_empty() and selected_variant_index < data.production_variants.size():
		var variant = data.production_variants[selected_variant_index]
		# Try to find item data for the resource to get its icon
		var resource_id = variant.get("resource_id", "")
		if resource_id:
			var item_data = GameManager.get_item_data(resource_id)
			if item_data and item_data.icon:
				product_sprite.texture = item_data.icon
				product_sprite.visible = true
			else:
				product_sprite.visible = false
		else:
			product_sprite.visible = false
	elif product_sprite:
		product_sprite.visible = false

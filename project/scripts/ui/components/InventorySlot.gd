class_name InventorySlot
extends Button

signal slot_selected(building_instance: BuildingInstance)
signal context_menu_requested(building_instance: BuildingInstance, global_pos: Vector2)

var building_instance: BuildingInstance

@onready var shape_display: Control = %ShapeDisplay
@onready var name_label: Label = %NameLabel
@onready var level_label: Label = %LevelLabel

func setup(instance: BuildingInstance) -> void:
	building_instance = instance
	var data = instance.data
	
	name_label.text = data.name
	level_label.text = "Lvl %d" % instance.level
	
	# Standardize size
	custom_minimum_size = Vector2(100, 120)
	
	# Apply background style
	var bg_texture = load("res://assets/tiles/1x1-tile.png")
	if bg_texture:
		var style = StyleBoxTexture.new()
		style.texture = bg_texture
		style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
		style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
		style.modulate_color = Color(0.8, 0.8, 0.8, 1.0)
		add_theme_stylebox_override("normal", style)
		add_theme_stylebox_override("hover", style)
		add_theme_stylebox_override("pressed", style)
		add_theme_stylebox_override("disabled", style)
		add_theme_stylebox_override("focus", style)

	if not shape_display.resized.is_connected(_on_shape_display_resized):
		shape_display.resized.connect(_on_shape_display_resized)
	
	_render_shape()
	
	var rarity_names = ["Common", "Uncommon", "Rare", "Legendary"]
	var rarity_str = rarity_names[data.rarity] if data.rarity >= 0 and data.rarity < rarity_names.size() else "Unknown"
	
	tooltip_text = "%s\n%s\n\nProduction: %.1f/s\nRarity: %s\n\n%s" % [
		data.name,
		data.description,
		data.get_production_at_level(instance.level),
		rarity_str,
		data.flavor_text
	]

	# Defer rendering to ensure size is calculated
	# call_deferred("_render_shape") # Removed in favor of resized signal

func _on_shape_display_resized() -> void:
	_render_shape()

func _render_shape() -> void:
	# Clear previous shape
	for child in shape_display.get_children():
		child.queue_free()
	
	if not building_instance or not building_instance.data or building_instance.data.shape_pattern.is_empty():
		return
		
	var data = building_instance.data
		
	# Calculate bounds
	var min_x = 999
	var max_x = -999
	var min_y = 999
	var max_y = -999
	
	for pos in data.shape_pattern:
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_y = min(min_y, pos.y)
		max_y = max(max_y, pos.y)
	
	var width_cells = (max_x - min_x) + 1
	var height_cells = (max_y - min_y) + 1
	
	# Determine cell size to fit in display (approx 60x60 area available)
	# Use full available space
	var available_width = shape_display.size.x
	var available_height = shape_display.size.y
	if available_width <= 0: available_width = 60.0
	if available_height <= 0: available_height = 60.0
	
	var cell_size = min(available_width / width_cells, available_height / height_cells)
	# Removed cap to allow full size
	
	# Center the shape
	var total_width = width_cells * cell_size
	var total_height = height_cells * cell_size
	var start_offset = Vector2(
		(shape_display.size.x - total_width) / 2,
		(shape_display.size.y - total_height) / 2
	)
	
	# Draw background grid cells (footprint)
	var tile_texture = load("res://assets/tiles/1x1-tile.png")
	for pos in data.shape_pattern:
		var bg_rect = TextureRect.new()
		shape_display.add_child(bg_rect)
		bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if tile_texture:
			bg_rect.texture = tile_texture
			bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		else:
			# Fallback if texture missing
			var color_rect = ColorRect.new()
			bg_rect.add_child(color_rect)
			color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			color_rect.color = Color(0.1, 0.1, 0.1, 0.5)
			
		bg_rect.size = Vector2(cell_size, cell_size)
		
		# Adjust pos relative to min bounds
		var rel_x = pos.x - min_x
		var rel_y = pos.y - min_y
		
		bg_rect.position = start_offset + Vector2(rel_x * cell_size, rel_y * cell_size)

	# Draw texture on top
	if data.texture:
		var texture_rect = TextureRect.new()
		shape_display.add_child(texture_rect)
		texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.texture = data.texture
		
		texture_rect.size = Vector2(total_width, total_height)
		texture_rect.position = start_offset

func _on_pressed() -> void:
	if building_instance:
		slot_selected.emit(building_instance)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if building_instance:
				context_menu_requested.emit(building_instance, get_global_mouse_position())

func _get_drag_data(at_position: Vector2) -> Variant:
	if not building_instance:
		return null
		
	var preview = Button.new()
	preview.text = building_instance.data.name
	preview.icon = building_instance.data.texture
	preview.expand_icon = true
	preview.custom_minimum_size = Vector2(64, 64)
	preview.modulate.a = 0.8
	set_drag_preview(preview)
	
	return {
		"type": "merge_building",
		"instance": building_instance,
		"source_slot": self
	}

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("type") or data.type != "merge_building":
		return false
		
	var source_instance = data.instance
	
	# Cannot merge with self
	if source_instance == building_instance:
		return false
		
	# Must be same ID
	if source_instance.data.id != building_instance.data.id:
		return false
		
	# Must be same level
	if source_instance.level != building_instance.level:
		return false
		
	# Must not be max level
	if building_instance.level >= building_instance.data.max_level:
		return false
		
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var source_instance = data.instance
	GameManager.merge_buildings(source_instance, building_instance)


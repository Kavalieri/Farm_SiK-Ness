class_name GridManager
extends Node2D

signal building_placed(building_data: Resource, grid_pos: Vector2i)
signal building_selected(building_entity: Node2D)

@export_group("Grid Settings")
@export var cell_size: Vector2i = Vector2i(64, 64)
@export var grid_size: Vector2i = Vector2i(10, 10)

# DEBUG: Temporary for testing
@export var debug_building_data: BuildingData
@export var debug_building_scene: PackedScene

# Dictionary to store grid state. Key: Vector2i (coords), Value: BuildingEntity (or null)
var _grid_state: Dictionary = {}
var _click_start_pos: Vector2
var selected_building_node: Node2D = null

var ghost_building: Node2D
var ghost_scene = preload("res://scenes/game/GhostBuilding.tscn")
var shipping_bin_scene = preload("res://scenes/game/ShippingBin.tscn")

@onready var ground_layer: TileMapLayer = %GroundLayer
@onready var buildings_container: Node2D = %BuildingsContainer
@onready var ghost_container: Node2D = %GhostContainer

func _ready() -> void:
	print("GridManager Ready")
	z_index = 1 # Ensure grid is drawn on top of background
	_initialize_grid()
	queue_redraw() # Force draw grid lines
	
	# Load debug resources if not set in inspector
	if not debug_building_data:
		debug_building_data = load("res://resources/data/buildings/silo.tres")
	if not debug_building_scene:
		debug_building_scene = load("res://scenes/game/BuildingEntity.tscn")
		
	GameManager.game_restarted.connect(_on_game_restarted)

func _process(_delta: float) -> void:
	_update_ghost()

func _update_ghost() -> void:
	if not GameManager.placing_building:
		if ghost_building:
			ghost_building.queue_free()
			ghost_building = null
		return

	var data = GameManager.placing_building.data

	if not ghost_building:
		ghost_building = ghost_scene.instantiate()
		ghost_container.add_child(ghost_building)
		ghost_building.setup(data, cell_size)
	elif ghost_building.data != data:
		# Update existing ghost with new data
		ghost_building.setup(data, cell_size)
	
	var mouse_pos = get_global_mouse_position()
	var grid_pos = world_to_grid(mouse_pos)
	ghost_building.position = grid_to_world(grid_pos)
	
	var is_valid = can_place_building(grid_pos, data.shape_pattern)
	ghost_building.set_valid(is_valid)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_click_start_pos = event.position
			else:
				# On Release
				# Check if it was a drag (pan) or a click
				if event.position.distance_to(_click_start_pos) > 10.0:
					return # It was a drag, ignore placement/selection
				
				var grid_pos = world_to_grid(get_global_mouse_position())
				
				if GameManager.placing_building:
					var instance = GameManager.placing_building
					var data = instance.data
					
					# Handle Placement
					if can_place_building(grid_pos, data.shape_pattern):
						var scene_to_place = debug_building_scene
						
						# Prioritize custom scene from data
						if data.custom_scene:
							scene_to_place = data.custom_scene
						elif data.id == "shipping_bin":
							scene_to_place = shipping_bin_scene
							
						place_building(scene_to_place, grid_pos, instance)
						
						# Remove from inventory (find first instance)
						var idx = GameManager.inventory.find(instance)
						if idx != -1:
							GameManager.remove_building_from_inventory(idx)
						
						# Deselect after placement
						GameManager.placing_building = null
				else:
					# Handle Selection
					if is_valid_grid_pos(grid_pos) and _grid_state.has(grid_pos):
						var building = _grid_state[grid_pos]
						if building:
							selected_building_node = building
							building_selected.emit(building)
							print("Selected building: ", building.name)
							queue_redraw()
					else:
						# Deselect if clicking empty space?
						selected_building_node = null
						building_selected.emit(null)
						queue_redraw()
		
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Cancel placement
			if GameManager.placing_building:
				GameManager.placing_building = null
				print("Placement cancelled")
			else:
				# Deselect on right click too
				selected_building_node = null
				building_selected.emit(null)
				queue_redraw()

func _initialize_grid() -> void:
	# Initialize empty grid or load from save
	pass

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(world_pos / Vector2(cell_size))

func get_neighbors(grid_pos: Vector2i, shape: Array[Vector2i]) -> Array:
	var neighbors: Array = []
	var checked_ids: Dictionary = {} # To avoid duplicates
	
	# Directions: Up, Down, Left, Right
	var directions = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	
	for cell in shape:
		var cell_world_pos = grid_pos + cell
		
		for dir in directions:
			var neighbor_pos = cell_world_pos + dir
			
			# Skip if this neighbor pos is part of the building itself
			var is_self = false
			for self_cell in shape:
				if (grid_pos + self_cell) == neighbor_pos:
					is_self = true
					break
			if is_self:
				continue
				
			if _grid_state.has(neighbor_pos):
				var neighbor = _grid_state[neighbor_pos]
				if neighbor and not checked_ids.has(neighbor.get_instance_id()):
					if neighbor is Node2D: # Use Node2D instead of BuildingEntity to avoid cyclic dep
						neighbors.append(neighbor)
					checked_ids[neighbor.get_instance_id()] = true
					
	return neighbors

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

func place_building(scene: PackedScene, grid_pos: Vector2i, instance_or_data) -> void:
	var data: BuildingData
	var level: int = 1
	var variant: int = 0
	
	if instance_or_data is BuildingInstance:
		data = instance_or_data.data
		level = instance_or_data.level
		variant = instance_or_data.selected_variant_index
	elif instance_or_data is BuildingData:
		data = instance_or_data
	else:
		push_error("Invalid data passed to place_building")
		return

	var building = scene.instantiate()
	buildings_container.add_child(building)
	building.setup(data, cell_size)
	building.position = grid_to_world(grid_pos)
	
	# Set level and variant if supported
	if "level" in building:
		building.level = level
	if "selected_variant_index" in building:
		building.selected_variant_index = variant
		
	# Force update production stats with new level/variant
	if building.has_method("_update_production_stats"):
		building._update_production_stats()
	
	# Update grid state
	for offset in data.shape_pattern:
		var pos = grid_pos + offset
		_grid_state[pos] = building
	
	building_placed.emit(data, grid_pos)
	
	# Add XP for placing building
	GameManager.add_xp(10)
	
	# Update synergies
	var neighbors = get_neighbors(grid_pos, data.shape_pattern)
	
	# Update self
	building.update_synergies(neighbors)
	
	# Update neighbors
	for neighbor in neighbors:
		if neighbor and neighbor.data:
			var neighbor_grid_pos = world_to_grid(neighbor.position)
			var neighbor_neighbors = get_neighbors(neighbor_grid_pos, neighbor.data.shape_pattern)
			neighbor.update_synergies(neighbor_neighbors)
	
	# GameManager.request_save() # Removed to avoid save loop during load and double save on placement

func _draw() -> void:
	# Draw grid lines for debugging
	var color = Color(1, 1, 1, 0.3)
	for x in range(grid_size.x + 1):
		var start = Vector2(x * cell_size.x, 0)
		var end = Vector2(x * cell_size.x, grid_size.y * cell_size.y)
		draw_line(start, end, color)
	
	for y in range(grid_size.y + 1):
		var start = Vector2(0, y * cell_size.y)
		var end = Vector2(grid_size.x * cell_size.x, y * cell_size.y)
		draw_line(start, end, color)
		
	# Draw Synergy Lines
	if is_instance_valid(selected_building_node) and selected_building_node is BuildingEntity and selected_building_node.data:
		var center_start = selected_building_node.position + (Vector2(cell_size) * 0.5)
		# Adjust center based on shape?
		# BuildingEntity position is top-left of the bounding box.
		# Let's just use the center of the first cell for now, or center of the bounding box.
		# Better: Center of the entity.
		# If shape is 2x2, center is + cell_size.
		
		# Calculate center of the building
		var min_x = 0; var max_x = 0; var min_y = 0; var max_y = 0
		if not selected_building_node.data.shape_pattern.is_empty():
			min_x = selected_building_node.data.shape_pattern[0].x
			max_x = selected_building_node.data.shape_pattern[0].x
			min_y = selected_building_node.data.shape_pattern[0].y
			max_y = selected_building_node.data.shape_pattern[0].y
			for pos in selected_building_node.data.shape_pattern:
				min_x = min(min_x, pos.x); max_x = max(max_x, pos.x)
				min_y = min(min_y, pos.y); max_y = max(max_y, pos.y)
		
		var width_cells = (max_x - min_x) + 1
		var height_cells = (max_y - min_y) + 1
		center_start = selected_building_node.position + Vector2(width_cells * cell_size.x * 0.5, height_cells * cell_size.y * 0.5)
		
		var grid_pos = world_to_grid(selected_building_node.position)
		var neighbors = get_neighbors(grid_pos, selected_building_node.data.shape_pattern)
		
		for neighbor in neighbors:
			if not neighbor.data: continue
			
			# Check if synergy exists (either way)
			var has_synergy = false
			
			# 1. Selected benefits from Neighbor
			for tag in neighbor.data.tags:
				if selected_building_node.data.synergy_rules.has(tag):
					has_synergy = true
					break
				# Check complex keys
				for key in selected_building_node.data.synergy_rules:
					if key.begins_with(tag + ":"):
						has_synergy = true
						break
			
			# 2. Neighbor benefits from Selected
			if not has_synergy:
				for tag in selected_building_node.data.tags:
					if neighbor.data.synergy_rules.has(tag):
						has_synergy = true
						break
					for key in neighbor.data.synergy_rules:
						if key.begins_with(tag + ":"):
							has_synergy = true
							break
			
			if has_synergy:
				# Calculate neighbor center
				var n_min_x = 0; var n_max_x = 0; var n_min_y = 0; var n_max_y = 0
				if not neighbor.data.shape_pattern.is_empty():
					n_min_x = neighbor.data.shape_pattern[0].x
					n_max_x = neighbor.data.shape_pattern[0].x
					n_min_y = neighbor.data.shape_pattern[0].y
					n_max_y = neighbor.data.shape_pattern[0].y
					for pos in neighbor.data.shape_pattern:
						n_min_x = min(n_min_x, pos.x); n_max_x = max(n_max_x, pos.x)
						n_min_y = min(n_min_y, pos.y); n_max_y = max(n_max_y, pos.y)
				var n_width = (n_max_x - n_min_x) + 1
				var n_height = (n_max_y - n_min_y) + 1
				var center_end = neighbor.position + Vector2(n_width * cell_size.x * 0.5, n_height * cell_size.y * 0.5)
				
				draw_line(center_start, center_end, Color.GREEN, 3.0)

func get_save_data() -> Array:
	var buildings_data = []
	for child in buildings_container.get_children():
		if child is BuildingEntity and child.data:
			var grid_pos = world_to_grid(child.position)
			var entry = {
				"path": child.data.resource_path,
				"grid_x": grid_pos.x,
				"grid_y": grid_pos.y,
				"level": child.level
			}
			if "selected_variant_index" in child:
				entry["variant"] = child.selected_variant_index
			buildings_data.append(entry)
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
					var level = entry.get("level", 1)
					var variant = entry.get("variant", 0)
					
					# Create temp instance to pass data
					var instance = BuildingInstance.new(res, level, 0, variant)
					
					var scene_to_place = debug_building_scene
					if res.custom_scene:
						scene_to_place = res.custom_scene
					elif res.id == "shipping_bin":
						scene_to_place = shipping_bin_scene
						
					place_building(scene_to_place, grid_pos, instance)

func remove_building(building: Node2D) -> void:
	if not building or not building is BuildingEntity:
		return
		
	var grid_pos = world_to_grid(building.position)
	var data = building.data
	
	# 1. Identify neighbors before removal (to update them later)
	var neighbors = get_neighbors(grid_pos, data.shape_pattern)
	
	# 2. Remove from grid state
	for offset in data.shape_pattern:
		var pos = grid_pos + offset
		if _grid_state.has(pos) and _grid_state[pos] == building:
			_grid_state.erase(pos)
			
	# 3. Update neighbors (they will now see empty space where this building was)
	for neighbor in neighbors:
		if neighbor and neighbor.data:
			var neighbor_grid_pos = world_to_grid(neighbor.position)
			var neighbor_neighbors = get_neighbors(neighbor_grid_pos, neighbor.data.shape_pattern)
			neighbor.update_synergies(neighbor_neighbors)
			
	# 4. Remove the node
	if selected_building_node == building:
		selected_building_node = null
		building_selected.emit(null)
		queue_redraw()
		
	building.queue_free()

func _on_game_restarted() -> void:
	# Clear all buildings
	for coords in _grid_state.keys():
		var building = _grid_state[coords]
		if is_instance_valid(building):
			building.queue_free()
	_grid_state.clear()
	
	# Re-initialize grid (shipping bin etc)
	_initialize_grid()

class_name MarketManager
extends Node

# Path to building resources
const BUILDINGS_PATH = "res://resources/data/buildings/"

var available_buildings: Array[BuildingData] = []

func _ready() -> void:
	load_all_buildings()

func load_all_buildings() -> void:
	available_buildings.clear()
	var dir = DirAccess.open(BUILDINGS_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Handle .remap extension for exported builds
			if !dir.current_is_dir():
				var clean_name = file_name
				if file_name.ends_with(".remap"):
					clean_name = file_name.replace(".remap", "")
				
				if clean_name.ends_with(".tres") or clean_name.ends_with(".res"):
					var resource = load(BUILDINGS_PATH + clean_name)
					if resource is BuildingData:
						# Only add if allowed in market pool
						if resource.in_market_pool:
							available_buildings.append(resource)
			file_name = dir.get_next()
	else:
		push_error("Failed to open buildings directory: " + BUILDINGS_PATH)

func generate_draft_options(count: int = 3) -> Array[BuildingData]:
	var options: Array[BuildingData] = []
	if available_buildings.is_empty():
		return options
	
	# TODO: Implement proper weighted random based on rarity and player level
	for i in range(count):
		var pick = available_buildings.pick_random()
		options.append(pick)
		
	return options

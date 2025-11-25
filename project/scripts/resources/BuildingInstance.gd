class_name BuildingInstance
extends Resource

# Wrapper for BuildingData with state (level, xp)
# Ensures persistence of building stats
@export var data: BuildingData
@export var level: int = 1
@export var xp: int = 0
@export var selected_variant_index: int = 0

func _init(p_data: BuildingData = null, p_level: int = 1, p_xp: int = 0, p_variant: int = 0) -> void:
	data = p_data
	level = p_level
	xp = p_xp
	selected_variant_index = p_variant

class_name BuildingInstance
extends Resource

@export var data: BuildingData
@export var level: int = 1
@export var xp: int = 0

func _init(p_data: BuildingData = null, p_level: int = 1, p_xp: int = 0) -> void:
	data = p_data
	level = p_level
	xp = p_xp

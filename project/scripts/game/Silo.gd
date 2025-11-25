class_name Silo
extends BuildingEntity

@export var base_storage: float = 50.0

func setup(building_data: BuildingData, cell_size: Vector2i) -> void:
	super.setup(building_data, cell_size)
	
	# Override from resource if available
	if data and data.custom_stats.has("storage"):
		base_storage = float(data.custom_stats["storage"])
		
	_apply_storage()
	
	# Ensure visual feedback is disabled even if setup re-enabled it
	if production_timer: production_timer.stop()
	if progress_bar: progress_bar.visible = false

func _ready() -> void:
	# If placed via scene editor
	if data:
		_apply_storage()
	
	# Silos don't produce
	if production_timer:
		production_timer.stop()
	if progress_bar:
		progress_bar.visible = false

func _exit_tree() -> void:
	GameManager.max_storage -= get_total_storage()

func upgrade() -> void:
	# Remove old storage amount
	GameManager.max_storage -= get_total_storage()
	super.upgrade()
	# Add new storage amount
	_apply_storage()

func get_total_storage() -> float:
	return base_storage * level

func _apply_storage() -> void:
	GameManager.max_storage += get_total_storage()

func _on_production_timer_timeout() -> void:
	pass # Do nothing

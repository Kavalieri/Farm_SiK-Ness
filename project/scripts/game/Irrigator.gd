class_name Irrigator
extends BuildingEntity

func setup(building_data: BuildingData, cell_size: Vector2i) -> void:
	super.setup(building_data, cell_size)
	if production_timer: production_timer.stop()
	if progress_bar: progress_bar.visible = false

func _ready() -> void:
	# Irrigators don't produce
	if production_timer:
		production_timer.stop()
	if progress_bar:
		progress_bar.visible = false

func _on_production_timer_timeout() -> void:
	pass # Do nothing

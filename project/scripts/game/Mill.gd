class_name Mill
extends BuildingEntity

@export var input_resource: String = "wheat"
@export var output_resource: String = "wheat_flour"
@export var conversion_amount: float = 10.0

func setup(building_data: BuildingData, cell_size: Vector2i) -> void:
	super.setup(building_data, cell_size)
	_update_recipe()

func _update_recipe() -> void:
	if not data: return
	
	# Default values from custom_stats (fallback)
	input_resource = data.custom_stats.get("input", "wheat")
	output_resource = data.custom_stats.get("output", "wheat_flour")
	conversion_amount = float(data.custom_stats.get("amount", 10.0))
	
	# Override from selected variant
	if not data.production_variants.is_empty() and selected_variant_index < data.production_variants.size():
		var variant = data.production_variants[selected_variant_index]
		if variant.has("input"): input_resource = variant.input
		if variant.has("output"): output_resource = variant.output
		if variant.has("amount"): conversion_amount = float(variant.amount)

func _on_production_timer_timeout() -> void:
	# Check if we have input
	if GameManager.get_resource_count(input_resource) >= conversion_amount:
		GameManager.consume_resource(input_resource, conversion_amount)
		# Output amount is usually 1 for processors unless specified otherwise
		# Let's assume 1 output for now, or add 'output_amount' to variant
		var added = GameManager.add_resource(output_resource, 1.0)
		
		if added > 0:
			_spawn_floating_text("+1", Color.YELLOW)
		# TODO: Visual feedback
	else:
		# Idle - maybe show visual warning?
		pass

# Override to update recipe when variant changes (if we implement variant switching at runtime)
func _update_production_stats() -> void:
	super._update_production_stats()
	_update_recipe()

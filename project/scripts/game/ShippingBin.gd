class_name ShippingBin
extends BuildingEntity

@export var sell_rate: float = 5.0 # Products per second
@export var price_per_product: float = 1.0

func setup(building_data: BuildingData, cell_size: Vector2i) -> void:
	super.setup(building_data, cell_size)
	
	# Ensure timer is running
	if production_timer.is_stopped():
		production_timer.start()

func _ready() -> void:
	# Connect to the inherited production_timer
	production_timer.timeout.connect(_on_timer_timeout)
	production_timer.start()

func _on_timer_timeout() -> void:
	var sold = GameManager.consume_products(sell_rate)
	if sold > 0:
		var income = sold * price_per_product
		GameManager.add_money(income)
		# TODO: Visual feedback (floating text)

class_name ShippingBin
extends BuildingEntity

@export var base_sell_rate: float = 5.0 # Products per second at level 2+
@export var price_per_product: float = 1.0

var current_sell_rate: float = 0.0

# Dictionary: Resource ID -> Boolean (True = Sell, False = Store)
var sell_settings: Dictionary = {
	"wheat": true,
	"flour": true
}

func setup(building_data: BuildingData, cell_size: Vector2i) -> void:
	super.setup(building_data, cell_size)
	
	# ShippingBin needs the timer even if base_production is 0
	if not production_timer.timeout.is_connected(_on_timer_timeout):
		production_timer.timeout.connect(_on_timer_timeout)
	
	_update_production_stats()

func _ready() -> void:
	# If placed via scene editor (not setup), ensure timer works
	if production_timer:
		if not production_timer.timeout.is_connected(_on_timer_timeout):
			production_timer.timeout.connect(_on_timer_timeout)
		if production_timer.is_stopped():
			production_timer.start()
	_update_production_stats()

func _update_production_stats() -> void:
	# Level 1: Inactive (No auto-sell)
	# Level 2: Auto-sell every 60s
	# Level 3+: Reduce interval
	if level == 1:
		current_sell_rate = 0.0
		if production_timer:
			production_timer.stop()
		if progress_bar:
			progress_bar.visible = false
	else:
		# Level 2 base interval: 60s
		# Reduce by 5s per level after 2
		var interval = max(10.0, 60.0 - ((level - 2) * 5.0))
		
		if production_timer:
			production_timer.wait_time = interval
			if production_timer.is_stopped():
				production_timer.start()
		
		if progress_bar:
			progress_bar.visible = true
			
		# Sell amount (per cycle)
		current_sell_rate = 100.0 + ((level - 2) * 50.0)

func _on_production_timer_timeout() -> void:
	# Override base behavior to prevent double production if data has base_production > 0
	pass

func _on_timer_timeout() -> void:
	if current_sell_rate <= 0:
		return
		
	var remaining_capacity = current_sell_rate
	var total_sold = 0.0
	var total_income = 0.0
	
	# Iterate through resources
	for resource_id in GameManager.resources.keys():
		if remaining_capacity <= 0:
			break
			
		# Check if enabled for selling
		if sell_settings.get(resource_id, true):
			var available = GameManager.get_resource_count(resource_id)
			if available > 0:
				var to_sell = min(available, remaining_capacity)
				var sold = GameManager.consume_resource(resource_id, to_sell)
				
				# Calculate price from ItemData
				var price = price_per_product
				var item_data = GameManager.get_item_data(resource_id)
				if item_data:
					price = item_data.base_value
				
				total_income += sold * price
				total_sold += sold
				remaining_capacity -= sold
	
	if total_sold > 0:
		GameManager.add_money(total_income)
		print("ShippingBin sold ", total_sold, " items for $", total_income)
		# TODO: Visual feedback (floating text)

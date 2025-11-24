class_name InventoryPanel
extends PanelContainer

var slot_scene = preload("res://scenes/ui/components/InventorySlot.tscn")

@onready var grid_container: GridContainer = %GridContainer
@onready var close_button: Button = %CloseButton

func _ready() -> void:
	GameManager.inventory_changed.connect(_on_inventory_changed)
	_refresh_inventory()
	hide()

func open() -> void:
	show()
	_refresh_inventory()

func close() -> void:
	hide()

func _refresh_inventory() -> void:
	# Clear existing slots
	for child in grid_container.get_children():
		child.queue_free()
	
	# Create slots for each item in inventory
	for building in GameManager.inventory:
		var slot = slot_scene.instantiate()
		grid_container.add_child(slot)
		slot.setup(building)
		slot.slot_selected.connect(_on_slot_selected)

func _on_inventory_changed(_new_inventory: Array) -> void:
	if visible:
		_refresh_inventory()

func _on_slot_selected(building_data: BuildingData) -> void:
	# Select for placement
	GameManager.placing_building = building_data
	print("Selected from inventory: ", building_data.name)
	close()

func _on_close_button_pressed() -> void:
	close()

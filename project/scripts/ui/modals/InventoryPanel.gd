class_name InventoryPanel
extends PanelContainer

var slot_scene = preload("res://scenes/ui/components/InventorySlot.tscn")
var _selected_building_for_menu: BuildingInstance

@onready var grid_container: GridContainer = %GridContainer
@onready var close_button: Button = %CloseButton
@onready var context_menu: PopupMenu = %ContextMenu

func _ready() -> void:
	GameManager.inventory_changed.connect(_on_inventory_changed)
	
	# Setup Context Menu
	context_menu.add_item("Place", 0)
	context_menu.add_item("Details", 1)
	context_menu.add_item("Sell", 2)
	context_menu.set_item_disabled(2, true) # Disable sell for now
	
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
		slot.context_menu_requested.connect(_on_slot_context_menu)

func _on_inventory_changed(_new_inventory: Array) -> void:
	if visible:
		_refresh_inventory()

func _on_slot_selected(building_instance: BuildingInstance) -> void:
	# Select for placement
	GameManager.placing_building = building_instance
	print("Selected from inventory: ", building_instance.data.name)
	close()

func _on_slot_context_menu(building_data: BuildingData, pos: Vector2) -> void:
	_selected_building_for_menu = building_data
	context_menu.position = Vector2i(pos)
	context_menu.popup()

func _on_context_menu_id_pressed(id: int) -> void:
	if not _selected_building_for_menu:
		return
		
	match id:
		0: # Place
			_on_slot_selected(_selected_building_for_menu)
		1: # Details
			print("Show details for: ", _selected_building_for_menu.name)
			# TODO: Open detail inspector
		2: # Sell
			print("Sell: ", _selected_building_for_menu.name)

func _on_close_button_pressed() -> void:
	close()

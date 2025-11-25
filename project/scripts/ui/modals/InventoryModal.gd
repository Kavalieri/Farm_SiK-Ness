class_name InventoryModal
extends PanelContainer

@onready var item_list_container: VBoxContainer = %ItemListContainer
@onready var close_button: Button = %CloseButton
@onready var total_weight_label: Label = %TotalWeightLabel

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(queue_free)
	_update_list()
	GameManager.resources_changed.connect(func(_res): _update_list())

func _update_list() -> void:
	for child in item_list_container.get_children():
		child.queue_free()
		
	var total_weight = 0.0
	
	for id in GameManager.resources:
		var amount = GameManager.resources[id]
		if amount <= 0: continue
		
		var item_data = GameManager.get_item_data(id)
		var item_name = id.capitalize()
		var weight = 1.0
		var value = 1.0
		var icon = null
		
		if item_data:
			item_name = item_data.name
			weight = item_data.weight
			value = item_data.base_value
			icon = item_data.icon
			
		var total_item_weight = amount * weight
		total_weight += total_item_weight
		
		var row = HBoxContainer.new()
		
		var icon_rect = TextureRect.new()
		icon_rect.texture = icon
		icon_rect.custom_minimum_size = Vector2(32, 32)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon_rect)
		
		var name_lbl = Label.new()
		name_lbl.text = item_name
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_lbl)
		
		var details_lbl = Label.new()
		details_lbl.text = "x%d | %.1f kg | $%d" % [amount, total_item_weight, amount * value]
		row.add_child(details_lbl)
		
		item_list_container.add_child(row)
		
	total_weight_label.text = "Capacidad: %.1f / %.1f" % [total_weight, GameManager.max_storage]

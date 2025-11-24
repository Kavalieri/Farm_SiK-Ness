class_name InventorySlot
extends Button

signal slot_selected(building_data: BuildingData)

var building_data: BuildingData

@onready var icon_rect: TextureRect = %IconRect

func setup(data: BuildingData) -> void:
	building_data = data
	icon_rect.texture = data.texture
	tooltip_text = data.name

func _on_pressed() -> void:
	if building_data:
		slot_selected.emit(building_data)

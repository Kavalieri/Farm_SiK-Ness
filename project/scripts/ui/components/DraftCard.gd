class_name DraftCard
extends PanelContainer

signal selected(building_data)

var building_data: BuildingData

@onready var name_label: Label = %NameLabel
@onready var icon_rect: TextureRect = %IconRect
@onready var cost_label: Label = %CostLabel
@onready var production_label: Label = %ProductionLabel
@onready var buy_button: Button = %BuyButton

func setup(data: BuildingData) -> void:
	building_data = data
	name_label.text = data.name
	icon_rect.texture = data.texture
	cost_label.text = "Cost: %d" % data.cost
	production_label.text = "Prod: %.1f/s" % data.base_production
	
	update_affordability()

func update_affordability() -> void:
	if building_data and GameManager.money < building_data.cost:
		buy_button.disabled = true
	else:
		buy_button.disabled = false

func _on_buy_button_pressed() -> void:
	if GameManager.spend_money(building_data.cost):
		selected.emit(building_data)

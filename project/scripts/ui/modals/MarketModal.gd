class_name MarketModal
extends PanelContainer

var market_manager: MarketManager
var draft_card_scene = preload("res://scenes/ui/components/DraftCard.tscn")

@onready var cards_container: HBoxContainer = %CardsContainer
@onready var close_button: Button = %CloseButton

func _ready() -> void:
	market_manager = MarketManager.new()
	add_child(market_manager)
	# Ensure buildings are loaded
	market_manager.load_all_buildings()
	hide()

func open() -> void:
	show()
	generate_cards()

func close() -> void:
	hide()

func generate_cards() -> void:
	# Clear existing cards
	for child in cards_container.get_children():
		child.queue_free()
	
	var options = market_manager.generate_draft_options(3)
	if options.is_empty():
		print("No buildings available for draft")
		return

	for building_data in options:
		var card = draft_card_scene.instantiate()
		cards_container.add_child(card)
		card.setup(building_data)
		card.selected.connect(_on_card_selected)

func _on_card_selected(building_data: BuildingData) -> void:
	GameManager.add_building_to_inventory(building_data)
	close()

func _on_close_button_pressed() -> void:
	close()

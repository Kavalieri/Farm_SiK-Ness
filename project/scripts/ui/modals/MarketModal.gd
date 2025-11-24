class_name MarketModal
extends PanelContainer

var draft_card_scene = preload("res://scenes/ui/components/DraftCard.tscn")

@onready var cards_container: HBoxContainer = %CardsContainer
@onready var close_button: Button = %CloseButton
@onready var rolls_label: Label = %RollsLabel
@onready var reroll_button: Button = %RerollButton

func _ready() -> void:
	GameManager.market_rolls_changed.connect(_on_rolls_changed)
	_update_rolls_label()
	hide()

func open() -> void:
	if visible:
		return
		
	show()
	_update_rolls_label()
	_update_reroll_button()
	
	if GameManager.current_market_options.is_empty():
		if GameManager.try_roll_market():
			render_cards()
		else:
			_show_no_rolls_message()
	else:
		render_cards()

func close() -> void:
	hide()

func render_cards() -> void:
	# Clear existing cards
	for child in cards_container.get_children():
		child.queue_free()
	
	var options = GameManager.current_market_options
	if options.is_empty():
		return

	for building_data in options:
		var card = draft_card_scene.instantiate()
		cards_container.add_child(card)
		card.setup(building_data)
		card.selected.connect(_on_card_selected)

func _show_no_rolls_message() -> void:
	for child in cards_container.get_children():
		child.queue_free()
	var label = Label.new()
	label.text = "No Rolls Available!\nWait for recharge."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cards_container.add_child(label)

func _on_card_selected(building_data: BuildingData) -> void:
	GameManager.add_building_to_inventory(building_data)
	# Auto-select for placement
	GameManager.placing_building = building_data
	GameManager.clear_market_options()
	print("Selected for placement: ", building_data.name)
	close()

func _on_close_button_pressed() -> void:
	close()

func _on_reroll_button_pressed() -> void:
	if GameManager.try_roll_market():
		render_cards()
	else:
		# Optional: Shake animation or sound
		pass

func _on_rolls_changed(_new_amount: int) -> void:
	_update_rolls_label()
	_update_reroll_button()

func _update_rolls_label() -> void:
	if rolls_label:
		rolls_label.text = "Rolls: %d/%d" % [GameManager.market_rolls, GameManager.MAX_MARKET_ROLLS]

func _update_reroll_button() -> void:
	if reroll_button:
		reroll_button.disabled = GameManager.market_rolls <= 0
		reroll_button.text = "REROLL (1 Roll)" if GameManager.market_rolls > 0 else "No Rolls"

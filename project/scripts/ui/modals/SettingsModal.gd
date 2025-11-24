class_name SettingsModal
extends PanelContainer

@onready var close_button: Button = %CloseButton
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var slot_selector: OptionButton = %SlotSelector
@onready var status_label: Label = %StatusLabel

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	
	_refresh_slots()
	hide()

func open() -> void:
	show()
	_refresh_slots()
	status_label.text = ""

func close() -> void:
	hide()

func _refresh_slots() -> void:
	slot_selector.clear()
	# Add fixed number of slots, e.g., 3
	for i in range(3):
		var slot_name = "Slot %d" % (i + 1)
		# Check if file exists to add info? For now just simple names
		slot_selector.add_item(slot_name, i)
	
	# Select current slot if set
	if SaveManager.current_slot != -1:
		slot_selector.selected = SaveManager.current_slot
	else:
		slot_selector.selected = 0

func _on_save_button_pressed() -> void:
	var slot_idx = slot_selector.get_selected_id()
	if SaveManager.save_game(slot_idx):
		status_label.text = "Game Saved to Slot %d!" % (slot_idx + 1)
		# Optional: Animation or color change
	else:
		status_label.text = "Save Failed!"

func _on_load_button_pressed() -> void:
	var slot_idx = slot_selector.get_selected_id()
	if SaveManager.load_game(slot_idx):
		status_label.text = "Game Loaded!"
		close() # Close menu on load to show game
	else:
		status_label.text = "Load Failed / No Save!"

func _on_close_button_pressed() -> void:
	close()

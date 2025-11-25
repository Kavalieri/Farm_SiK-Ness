class_name SettingsModal
extends PanelContainer

@onready var close_button: Button = %CloseButton
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var exit_button: Button = %ExitButton
@onready var slot_selector: OptionButton = %SlotSelector
@onready var status_label: Label = %StatusLabel

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_button_pressed)
	
	slot_selector.item_selected.connect(_on_slot_selected)
	
	_refresh_slots()
	hide()

func open() -> void:
	show()
	_refresh_slots()
	status_label.text = ""

func close() -> void:
	hide()

func _refresh_slots() -> void:
	var current_selection = slot_selector.selected
	slot_selector.clear()
	
	for i in range(3):
		var slot_name = "Slot %d" % (i + 1)
		if SaveManager.save_exists(i):
			var info = SaveManager.get_save_info(i)
			var level = info.get("level", 1)
			slot_name += " (Nivel %d)" % level
		else:
			slot_name += " (Vacío)"
			
		slot_selector.add_item(slot_name, i)
	
	# Restore selection or default
	if current_selection != -1 and current_selection < slot_selector.item_count:
		slot_selector.selected = current_selection
	elif SaveManager.current_slot != -1:
		slot_selector.selected = SaveManager.current_slot
	else:
		slot_selector.selected = 0
		
	_on_slot_selected(slot_selector.selected)

func _on_slot_selected(index: int) -> void:
	if index == -1: return
	var slot_idx = slot_selector.get_item_id(index)
	
	if SaveManager.save_exists(slot_idx):
		load_button.text = "CARGAR"
	else:
		load_button.text = "NUEVA PARTIDA"

func _on_save_button_pressed() -> void:
	var slot_idx = slot_selector.get_selected_id()
	if SaveManager.save_game(slot_idx):
		status_label.text = "Game Saved to Slot %d!" % (slot_idx + 1)
		# Optional: Animation or color change
	else:
		status_label.text = "Save Failed!"

func _on_load_button_pressed() -> void:
	var slot_idx = slot_selector.get_selected_id()
	
	if SaveManager.save_exists(slot_idx):
		if SaveManager.load_game(slot_idx):
			status_label.text = "Partida Cargada!"
			close()
		else:
			status_label.text = "Error al Cargar!"
	else:
		# Start New Game
		GameManager.start_new_game()
		SaveManager.current_slot = slot_idx
		SaveManager.save_game(slot_idx) # Initialize save file
		status_label.text = "Nueva Partida Creada!"
		_refresh_slots()
		close()

func _on_close_button_pressed() -> void:
	close()

func _on_exit_button_pressed() -> void:
	# Force save before exit
	if SaveManager.current_slot != -1:
		SaveManager.request_save()
	elif slot_selector.selected != -1:
		# If no slot is active but one is selected in UI, save to that one
		SaveManager.current_slot = slot_selector.get_selected_id()
		SaveManager.request_save()
	
	get_tree().quit()

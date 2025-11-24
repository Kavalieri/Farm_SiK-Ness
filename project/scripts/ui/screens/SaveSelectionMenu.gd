class_name SaveSelectionMenu
extends Control

const MAX_SLOTS = 3
var slot_card_scene = preload("res://scenes/ui/components/SaveSlotCard.tscn")

@onready var slots_container: VBoxContainer = %SlotsContainer
@onready var back_button: Button = %BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	_refresh_slots()

func _refresh_slots() -> void:
	for child in slots_container.get_children():
		child.queue_free()
		
	for i in range(MAX_SLOTS):
		var slot_idx = i
		var card = slot_card_scene.instantiate()
		slots_container.add_child(card)
		
		# Check if save exists
		var exists = SaveManager.save_exists(slot_idx)
		var info = {}
		if exists:
			info = SaveManager.get_save_info(slot_idx)
			
		card.setup(slot_idx, exists, info)
		card.play_requested.connect(_on_play_requested)
		card.delete_requested.connect(_on_delete_requested)

func _on_play_requested(slot_idx: int) -> void:
	SaveManager.current_slot = slot_idx
	# If save exists, load it? Or just set current slot and let MainGame load it?
	# Usually we load the scene, then MainGame loads the data.
	# But we need to know IF we should load.
	
	# If it's a new game (no save file), we just start fresh on that slot.
	# If it exists, we load it.
	
	# We can pass a parameter to MainGame or set a flag in SaveManager
	SaveManager.load_on_start = SaveManager.save_exists(slot_idx)
	
	get_tree().change_scene_to_file("res://scenes/game/MainGame.tscn")

func _on_delete_requested(slot_idx: int) -> void:
	SaveManager.delete_save(slot_idx)
	_refresh_slots()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/screens/MainMenu.tscn")

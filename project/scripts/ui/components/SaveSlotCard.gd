class_name SaveSlotCard
extends PanelContainer

signal play_requested(slot_idx: int)
signal delete_requested(slot_idx: int)

var slot_index: int

@onready var title_label: Label = %TitleLabel
@onready var info_label: Label = %InfoLabel
@onready var action_button: Button = %ActionButton
@onready var delete_button: Button = %DeleteButton

func setup(idx: int, exists: bool, info: Dictionary) -> void:
	slot_index = idx
	title_label.text = "Slot %d" % (idx + 1)
	
	if exists:
		var timestamp = info.get("timestamp", 0)
		var date_str = Time.get_datetime_string_from_unix_time(timestamp)
		var level = info.get("game_manager", {}).get("level", 1)
		var money = info.get("game_manager", {}).get("money", 0)
		
		info_label.text = "Level %d | $%.0f\n%s" % [level, money, date_str.replace("T", " ")]
		action_button.text = "CONTINUAR"
		delete_button.disabled = false
	else:
		info_label.text = "Vacío"
		action_button.text = "NUEVA PARTIDA"
		delete_button.disabled = true

func _on_action_button_pressed() -> void:
	play_requested.emit(slot_index)

func _on_delete_button_pressed() -> void:
	# TODO: Add confirmation dialog?
	delete_requested.emit(slot_index)

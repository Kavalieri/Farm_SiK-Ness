class_name MainMenu
extends Control

var save_selection_scene = preload("res://scenes/ui/screens/SaveSelectionMenu.tscn")
var settings_scene = preload("res://scenes/ui/modals/SettingsModal.tscn") # Or reuse the modal

@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	SaveManager.current_slot = -1 # Reset current slot to prevent auto-save in menu
	play_button.pressed.connect(_on_play_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(save_selection_scene)

func _on_settings_button_pressed() -> void:
	# TODO: Open settings
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()

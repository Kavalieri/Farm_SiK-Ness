class_name ResourceDisplay
extends HBoxContainer

@export var icon: Texture2D
@export var label_text: String = "0"

@onready var icon_rect: TextureRect = %IconRect
@onready var value_label: Label = %ValueLabel

func _ready() -> void:
	if icon:
		icon_rect.texture = icon
	value_label.text = label_text

func update_value(new_value: float) -> void:
	# TODO: Add tween animation
	value_label.text = str(int(new_value))

class_name FloatingText
extends Node2D

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func setup(text: String, color: Color = Color.WHITE) -> void:
	label.text = text
	label.modulate = color
	
	# Randomize slight position offset
	position += Vector2(randf_range(-10, 10), randf_range(-10, 10))

func _ready() -> void:
	animation_player.play("float_up")
	await animation_player.animation_finished
	queue_free()

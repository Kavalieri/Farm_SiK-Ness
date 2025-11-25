class_name ItemData
extends Resource

@export var id: String
@export var name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var base_value: float = 1.0
@export var weight: float = 1.0 ## Space occupied per unit in storage
@export_enum("Raw", "Processed", "Special") var type: int = 0

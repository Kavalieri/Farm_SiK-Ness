class_name BuildingData
extends Resource

@export_group("Identity")
@export var id: String
@export var name: String
@export var description: String
@export var texture: Texture2D

@export_group("Grid Properties")
## Array of Vector2i defining the shape relative to (0,0). Example: [(0,0), (1,0)] for 1x2.
@export var shape_pattern: Array[Vector2i] = [Vector2i(0,0)]

@export_group("Economy")
@export var base_production: float = 1.0
@export var cost: int = 100
@export_enum("Common", "Uncommon", "Rare", "Legendary") var rarity: int = 0
@export var spawn_weight: float = 1.0

@export_group("Synergies")
## Tags that identify this building (e.g., "crop", "water", "industrial")
@export var tags: Array[String] = []
## Dictionary mapping tag names to production multipliers.
## Example: {"water": 0.5} adds 50% base production per neighbor.
@export var synergy_rules: Dictionary = {}

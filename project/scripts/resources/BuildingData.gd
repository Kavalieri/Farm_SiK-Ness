class_name BuildingData
extends Resource

@export_group("Identity")
@export var id: String
@export var name: String
@export_multiline var description: String
@export_multiline var flavor_text: String = ""
@export var texture: Texture2D

@export_group("Grid Properties")
## Array of Vector2i defining the shape relative to (0,0). Example: [(0,0), (1,0)] for 1x2.
@export var shape_pattern: Array[Vector2i] = [Vector2i(0,0)]

@export_group("Economy")
@export var base_production: float = 1.0
@export var cost: int = 100
@export_enum("Common", "Uncommon", "Rare", "Legendary") var rarity: int = 0
@export var spawn_weight: float = 1.0

@export_group("Upgrades")
@export var max_level: int = 3
@export var upgrade_cost_base: int = 50
@export var upgrade_cost_factor: float = 1.5
@export var production_growth: float = 0.5 ## Added to base_production per level

@export_group("Synergies")
## Tags that identify this building (e.g., "crop", "water", "industrial")
@export var tags: Array[String] = []
## Dictionary mapping tag names to production multipliers.
## Example: {"water": 0.5} adds 50% base production per neighbor.
@export var synergy_rules: Dictionary = {}

@export_group("UI")
## Dictionary for custom stats to display. Key: Stat Name, Value: Value (String or Number)
## Example: {"Range": "2 Tiles", "Capacity": 100}
@export var custom_stats: Dictionary = {}

func get_upgrade_cost(current_level: int) -> int:
	return int(upgrade_cost_base * pow(upgrade_cost_factor, current_level - 1))

func get_production_at_level(level: int) -> float:
	return base_production + (production_growth * (level - 1))


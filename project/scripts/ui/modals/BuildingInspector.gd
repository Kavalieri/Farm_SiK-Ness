class_name BuildingInspector
extends PanelContainer

signal return_requested(building_entity: Node2D)

@onready var icon: TextureRect = $VBoxContainer/Header/Icon
@onready var name_label: Label = $VBoxContainer/Header/InfoBox/NameLabel
@onready var level_label: Label = $VBoxContainer/Header/InfoBox/LevelLabel
@onready var stats_label: RichTextLabel = $VBoxContainer/StatsLabel
# We will add these nodes to the scene next
@onready var description_label: Label = $VBoxContainer/DescriptionLabel
@onready var flavor_label: Label = $VBoxContainer/FlavorLabel
@onready var synergies_container: VBoxContainer = $VBoxContainer/SynergiesContainer
@onready var upgrade_button: Button = %UpgradeButton
@onready var close_button: Button = %CloseButton

var current_building_entity: Node2D # Reference to the actual building instance
var current_data: BuildingData
var current_level_val: int = 1

@onready var return_button: Button = %ReturnButton

func _ready() -> void:
	if upgrade_button:
		upgrade_button.pressed.connect(_on_upgrade_pressed)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	if return_button:
		return_button.pressed.connect(_on_return_pressed)

func setup(data: BuildingData, current_level: int = 1, building_instance: Node2D = null) -> void:
	if not data:
		return
	
	current_data = data
	current_level_val = current_level
	current_building_entity = building_instance
	
	# Show/Hide Return Button based on context (only if placed on grid)
	if return_button:
		return_button.visible = (current_building_entity != null and current_building_entity.get_parent().name == "BuildingsContainer")
		
	icon.texture = data.texture
	name_label.text = data.name
	level_label.text = "Nivel %d" % current_level
	
	# Description
	if description_label:
		description_label.text = data.description
	
	# Flavor Text
	if flavor_label:
		flavor_label.text = "[i]%s[/i]" % data.flavor_text if data.flavor_text else ""
	
	# Base Stats
	var production = data.get_production_at_level(current_level)
	var text = "[b]Producción Base:[/b] %.1f/s\n" % production
	
	# Custom Stats
	for key in data.custom_stats:
		text += "[b]%s:[/b] %s\n" % [key, str(data.custom_stats[key])]
		
	stats_label.text = text
	
	# Synergies List
	_populate_synergies(data)
	
	# Update Upgrade Button
	_update_upgrade_button()

func _update_upgrade_button() -> void:
	if not upgrade_button: return
	
	if current_level_val >= current_data.max_level:
		upgrade_button.text = "Nivel Máximo"
		upgrade_button.disabled = true
	else:
		var cost = current_data.get_upgrade_cost(current_level_val)
		upgrade_button.text = "Mejorar ($%d)" % cost
		upgrade_button.disabled = GameManager.money < cost

func _on_upgrade_pressed() -> void:
	if current_level_val >= current_data.max_level:
		return
		
	var cost = current_data.get_upgrade_cost(current_level_val)
	if GameManager.spend_money(cost):
		# Perform upgrade
		if current_building_entity and current_building_entity.has_method("upgrade"):
			current_building_entity.upgrade()
			current_level_val += 1
			
			# Refresh UI
			setup(current_data, current_level_val, current_building_entity)
			
			# Update dynamic stats if possible
			if current_building_entity is BuildingEntity:
				update_dynamic_stats(current_building_entity.current_production, [])
	else:
		# Feedback for not enough money
		upgrade_button.text = "Sin Fondos"
		var tween = create_tween()
		tween.tween_property(upgrade_button, "modulate", Color.RED, 0.2)
		tween.tween_property(upgrade_button, "modulate", Color.WHITE, 0.2)
		await tween.finished
		_update_upgrade_button()

func _on_close_pressed() -> void:
	visible = false


func _populate_synergies(data: BuildingData) -> void:
	if not synergies_container:
		return
		
	for child in synergies_container.get_children():
		child.queue_free()
		
	if data.synergy_rules.is_empty():
		var label = Label.new()
		label.text = "Sin sinergias conocidas."
		label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		synergies_container.add_child(label)
		return
		
	for tag in data.synergy_rules:
		var multiplier = data.synergy_rules[tag]
		var label = Label.new()
		var sign_str = "+" if multiplier > 0 else ""
		label.text = "%s%d%% por adyacencia a [%s]" % [sign_str, int(multiplier * 100), tag.capitalize()]
		synergies_container.add_child(label)

func update_dynamic_stats(current_production: float, active_synergies: Array) -> void:
	# Append dynamic info to stats
	var text = stats_label.text
	text += "\n[color=green][b]Producción Actual:[/b] %.1f/s[/color]" % current_production
	stats_label.text = text

func _on_return_pressed() -> void:
	if current_building_entity:
		return_requested.emit(current_building_entity)
		visible = false

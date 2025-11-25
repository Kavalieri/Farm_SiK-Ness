class_name BuildingInspector
extends Control

signal return_requested(building_entity: Node2D)

# UI Nodes (using unique names)
@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel
@onready var level_label: Label = %LevelLabel
@onready var type_label: Label = %TypeLabel
@onready var description_label: Label = %DescriptionLabel
@onready var flavor_label: RichTextLabel = %FlavorLabel
@onready var stats_label: RichTextLabel = %StatsLabel
@onready var variant_selector: OptionButton = %VariantSelector
@onready var synergies_list: VBoxContainer = %SynergiesList
@onready var sell_container: VBoxContainer = %SellContainer
@onready var sell_info_label: Label = %SellInfoLabel

# Buttons
@onready var upgrade_button: Button = %UpgradeButton
@onready var return_button: Button = %ReturnButton
@onready var sell_button: Button = %SellButton
@onready var close_button: Button = %CloseButton

var current_building_entity: Node2D
var current_data: BuildingData
var current_level_val: int = 1

@onready var panel_container: PanelContainer = $CenterContainer/Panel

func _ready() -> void:
	if upgrade_button: upgrade_button.pressed.connect(_on_upgrade_pressed)
	if close_button: close_button.pressed.connect(_on_close_pressed)
	if return_button: return_button.pressed.connect(_on_return_pressed)
	if sell_button: sell_button.pressed.connect(_on_sell_pressed)
	if variant_selector: variant_selector.item_selected.connect(_on_variant_selected)
	
	GameManager.products_changed.connect(_on_products_changed)
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	# Enforce Icon settings one last time
	if icon:
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Initial resize
	_on_viewport_resized()

func _on_viewport_resized() -> void:
	if not panel_container: return
	var viewport_size = get_viewport_rect().size
	var is_portrait = viewport_size.y > viewport_size.x
	
	if is_portrait:
		# In portrait, fill most of the width (e.g. 90%)
		panel_container.custom_minimum_size.x = viewport_size.x * 0.9
	else:
		# In landscape, keep a fixed readable width (e.g. 400px)
		panel_container.custom_minimum_size.x = 400
	
	# Limit height to avoid overflowing screen
	panel_container.custom_minimum_size.y = min(450, viewport_size.y * 0.8)


func setup(data: BuildingData, current_level: int = 1, building_instance: Node2D = null) -> void:
	if not data: return
	
	current_data = data
	current_level_val = current_level
	current_building_entity = building_instance
	
	_setup_header()
	_setup_description()
	_setup_stats()
	_setup_variants()
	_setup_synergies()
	_setup_footer()

func _setup_header() -> void:
	if icon: icon.texture = current_data.texture
	if name_label: name_label.text = current_data.name
	if level_label: level_label.text = "Nivel %d" % current_level_val
	
	if type_label:
		var type_str = "EDIFICIO"
		match current_data.type:
			BuildingData.BuildingType.PRODUCER: type_str = "PRODUCTOR"
			BuildingData.BuildingType.PROCESSOR: type_str = "PROCESADOR"
			BuildingData.BuildingType.STORAGE: type_str = "ALMACÉN"
			BuildingData.BuildingType.SUPPORT: type_str = "SOPORTE"
			BuildingData.BuildingType.LOGISTICS: type_str = "LOGÍSTICA"
		type_label.text = type_str

func _setup_description() -> void:
	if description_label: description_label.text = current_data.description
	if flavor_label:
		flavor_label.text = "[i]%s[/i]" % current_data.flavor_text if current_data.flavor_text else ""

func _setup_stats() -> void:
	var text = ""
	
	match current_data.type:
		BuildingData.BuildingType.PRODUCER:
			var production = current_data.get_production_at_level(current_level_val)
			text = "[b]Producción Base:[/b] %.1f/s\n" % production
			
			if _has_variant_info():
				var idx = current_building_entity.selected_variant_index
				if idx >= 0 and idx < current_data.production_variants.size():
					var variant = current_data.production_variants[idx]
					text += "[b]Cultivo:[/b] %s\n" % variant.name
					text += "[b]Intervalo:[/b] %.1fs\n" % variant.interval
					
		BuildingData.BuildingType.PROCESSOR:
			if _has_variant_info():
				var idx = current_building_entity.selected_variant_index
				if idx >= 0 and idx < current_data.production_variants.size():
					var variant = current_data.production_variants[idx]
					text += "[b]Receta:[/b] %s\n" % variant.name
					text += "[b]Input:[/b] %.0f %s\n" % [
						float(variant.get("amount", 10)), 
						str(variant.get("input", "??")).capitalize()
					]
					text += "[b]Output:[/b] 1 %s\n" % str(variant.get("output", "??")).capitalize()
					text += "[b]Tiempo:[/b] %.1fs\n" % variant.interval
			else:
				text = "[b]Procesador Industrial[/b]\n"
				
		BuildingData.BuildingType.STORAGE:
			var storage = 0.0
			if current_building_entity and current_building_entity.has_method("get_total_storage"):
				storage = current_building_entity.get_total_storage()
			elif current_data.custom_stats.has("storage"):
				storage = float(current_data.custom_stats["storage"]) * current_level_val
			text = "[b]Capacidad:[/b] +%.0f Items\n" % storage
			
		BuildingData.BuildingType.LOGISTICS:
			if current_building_entity is ShippingBin:
				var rate = current_building_entity.current_sell_rate
				if rate <= 0:
					text = "[b]Auto-Venta:[/b] Inactiva\n[color=red](Requiere Nivel 2)[/color]\n"
				else:
					var interval = 0.0
					if current_building_entity.production_timer:
						interval = current_building_entity.production_timer.wait_time
					text = "[b]Auto-Venta:[/b] %.0f items\n" % rate
					text += "[b]Intervalo:[/b] %.0fs\n" % interval

	# Custom Stats
	for key in current_data.custom_stats:
		if key == "storage" and current_data.type == BuildingData.BuildingType.STORAGE: continue
		if key == "input" or key == "output" or key == "amount": continue
		text += "[b]%s:[/b] %s\n" % [key, str(current_data.custom_stats[key])]
		
	if stats_label: stats_label.text = text
	
	# Dynamic Stats (Production)
	if current_building_entity is BuildingEntity:
		update_dynamic_stats(current_building_entity.current_production, [])

func _setup_variants() -> void:
	if not variant_selector: return
	variant_selector.visible = false
	variant_selector.clear()
	
	if current_data.production_variants.is_empty(): return
	if not _has_variant_info(): return
		
	variant_selector.visible = true
	for i in range(current_data.production_variants.size()):
		var variant = current_data.production_variants[i]
		var unlock_level = variant.get("unlock_level", 1)
		var is_unlocked = current_level_val >= unlock_level
		
		var label = variant.name
		if not is_unlocked: label += " (Nivel %d)" % unlock_level
			
		variant_selector.add_item(label, i)
		if variant.has("icon") and variant.icon:
			variant_selector.set_item_icon(i, variant.icon)
		elif variant.has("resource_id"):
			var item_data = GameManager.get_item_data(variant.resource_id)
			if item_data and item_data.icon:
				variant_selector.set_item_icon(i, item_data.icon)
			
		variant_selector.set_item_disabled(i, not is_unlocked)
		
	variant_selector.selected = current_building_entity.selected_variant_index

func _setup_synergies() -> void:
	if not synergies_list: return
	for child in synergies_list.get_children(): child.queue_free()
	
	if current_data.synergy_rules.is_empty():
		var label = Label.new()
		label.text = "Sin sinergias conocidas."
		label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		synergies_list.add_child(label)
		return
		
	for rule_key in current_data.synergy_rules:
		var multiplier = current_data.synergy_rules[rule_key]
		var label = Label.new()
		var sign_str = "+" if multiplier > 0 else ""
		
		var tag = rule_key
		var effect_desc = "Producción"
		
		if ":" in rule_key:
			var parts = rule_key.split(":")
			tag = parts[0]
			var effect = parts[1]
			match effect:
				"speed": effect_desc = "Velocidad"
				"value": effect_desc = "Valor"
				"production": effect_desc = "Producción"
		
		label.text = "%s%d%% %s por adyacencia a [%s]" % [
			sign_str, int(multiplier * 100), effect_desc, tag.capitalize()
		]
		synergies_list.add_child(label)

func _setup_footer() -> void:
	# Return Button
	if return_button:
		return_button.visible = (
			current_building_entity != null 
			and current_building_entity.get_parent().name == "BuildingsContainer"
		)
	
	# Sell/ShippingBin Logic
	if sell_container:
		if current_building_entity is ShippingBin:
			sell_container.visible = true
			_update_sell_info()
			_update_sell_settings_ui()
		else:
			sell_container.visible = false
			
	# Upgrade Button
	_update_upgrade_button()

func _update_upgrade_button() -> void:
	if not upgrade_button or not current_data: return
	if current_level_val >= current_data.max_level:
		upgrade_button.text = "Nivel Máximo"
		upgrade_button.disabled = true
	else:
		var cost = current_data.get_upgrade_cost(current_level_val)
		upgrade_button.text = "Mejorar ($%d)" % cost
		upgrade_button.disabled = GameManager.money < cost

func update_dynamic_stats(current_production: float, active_synergies: Array) -> void:
	if not stats_label: return
	# We append to the existing text, but we need to be careful not to duplicate if called multiple times
	# Ideally, we should regenerate stats, but for now let's just append if not present
	# Or better, just re-run _setup_stats() but that might be heavy.
	# Let's just update the label text with a specific marker or just append.
	
	# Simple approach: Re-run setup stats logic for the base text, then append dynamic
	# But _setup_stats sets the text. So we can just call _setup_stats() then append.
	# However, update_dynamic_stats is called from outside.
	
	# Let's just append a line at the end.
	var text = stats_label.text
	if "Producción Actual" in text:
		# Remove old dynamic line
		var lines = text.split("\n")
		var new_lines = []
		for line in lines:
			if not "Producción Actual" in line:
				new_lines.append(line)
		text = "\n".join(new_lines)
	
	text += "\n[color=green][b]Producción Actual:[/b] %.1f/s[/color]" % current_production
	stats_label.text = text

func _has_variant_info() -> bool:
	return (current_building_entity != null 
		and "selected_variant_index" in current_building_entity)

# Event Handlers
func _on_upgrade_pressed() -> void:
	if current_level_val >= current_data.max_level: return
	var cost = current_data.get_upgrade_cost(current_level_val)
	if GameManager.spend_money(cost):
		if current_building_entity and current_building_entity.has_method("upgrade"):
			current_building_entity.upgrade()
			current_level_val += 1
			setup(current_data, current_level_val, current_building_entity)
	else:
		upgrade_button.text = "Sin Fondos"
		var tween = create_tween()
		tween.tween_property(upgrade_button, "modulate", Color.RED, 0.2)
		tween.tween_property(upgrade_button, "modulate", Color.WHITE, 0.2)
		await tween.finished
		_update_upgrade_button()

func _on_close_pressed() -> void: visible = false

func _on_return_pressed() -> void:
	if current_building_entity:
		return_requested.emit(current_building_entity)
		visible = false

func _on_variant_selected(index: int) -> void:
	if _has_variant_info():
		current_building_entity.selected_variant_index = index
		if current_building_entity.has_method("_update_production_stats"):
			current_building_entity._update_production_stats()
		setup(current_data, current_level_val, current_building_entity)

func _on_products_changed(_current, _max) -> void:
	_update_upgrade_button()

# Shipping Bin Specifics (kept from original)
func _on_sell_pressed() -> void:
	if current_building_entity is ShippingBin:
		current_building_entity.sell_contents()
		_update_sell_info()

func _update_sell_info() -> void:
	if not sell_info_label or not (current_building_entity is ShippingBin): return
	var count = current_building_entity.inventory.size()
	var capacity = current_building_entity.storage_capacity
	var value = current_building_entity.calculate_total_value()
	sell_info_label.text = "Almacén: %d/%d - Valor: $%d" % [count, capacity, value]

func _update_sell_settings_ui() -> void:
	# Placeholder if we had more settings
	pass

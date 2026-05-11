extends Control

@onready var settings_panel = $SettingsPanel
@onready var debug_check = $SettingsPanel/VBoxContainer/DebugCheck
@onready var cheats_check = $SettingsPanel/VBoxContainer/CheatsCheck
@onready var fps_check = $SettingsPanel/VBoxContainer/FPSCheck
@onready var dps_check = $SettingsPanel/VBoxContainer/DPSCheck
@onready var main_menu = $CenterContainer
var ff_check: CheckButton

var upgrades_panel: Panel
var gold_display: Label
var upgrade_rows = {}

var character_panel: Control
var map_panel: Control

func _ready():
	# Load current state
	debug_check.button_pressed = Global.debug_enabled
	cheats_check.button_pressed = Global.cheats_enabled
	fps_check.button_pressed = Global.fps_enabled
	dps_check.button_pressed = Global.dps_enabled
	
	# Add Fast Forward check dynamically
	ff_check = CheckButton.new()
	ff_check.text = "Fast Forward Button"
	ff_check.button_pressed = Global.fast_forward_button_enabled
	ff_check.toggled.connect(_on_ff_check_toggled)
	$SettingsPanel/VBoxContainer.add_child(ff_check)
	$SettingsPanel/VBoxContainer.move_child(ff_check, $SettingsPanel/VBoxContainer.get_child_count() - 2) # Place before Back button
	
	# 1. Create Upgrades Button (Main Menu)
	var btn = Button.new()
	btn.text = "Upgrades"
	btn.pressed.connect(func(): _open_upgrades_panel())
	$CenterContainer/VBoxContainer.add_child(btn)
	$CenterContainer/VBoxContainer.move_child(btn, $CenterContainer/VBoxContainer.get_child_count() - 2) # Place before Quit

	# 2. Register Upgrades (ensure they exist in row registry before UI init)
	_register_upgrade("health", "Max Health (+10)", 100, 5, "res://Sprites/Vitality.png")
	_register_upgrade("damage", "Damage (+5%)", 150, 5, "res://Sprites/damage_icon.png")
	_register_upgrade("speed", "Speed (+20)", 120, 3, "res://Sprites/Boots.png")
	_register_upgrade("regeneration", "HP Regen (+0.5/s)", 200, 3, "res://Sprites/Regeneration.png")
	_register_upgrade("gold_gain", "Gold Drops (+100%)", 10000, 3, "res://Sprites/Gold.png")
	_register_upgrade("attack_speed", "Attack Speed (+15%)", 500, 3, "res://Sprites/attack_speed.png")
	_register_upgrade("defense", "Defense (+1)", 250, 5, "res://Sprites/Shield.png")

	_setup_upgrades_ui()
	_setup_selection_ui()

func _setup_selection_ui():
	# Character Selection Panel
	character_panel = Control.new() # Use Control instead of Panel for custom BG
	character_panel.visible = false
	character_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(character_panel)
	
	var char_bg = ColorRect.new()
	char_bg.color = Color(0.05, 0.05, 0.1, 1.0) # Very dark blue/black
	char_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	character_panel.add_child(char_bg)
	
	# Full-screen centering container
	var char_center = CenterContainer.new()
	char_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	character_panel.add_child(char_center)
	
	var char_vbox = VBoxContainer.new()
	char_center.add_child(char_vbox)
	
	var title = Label.new()
	title.text = "Select Character"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	char_vbox.add_child(title)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	char_vbox.add_child(spacer)
	
	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 30)
	grid.add_theme_constant_override("v_separation", 30)
	char_vbox.add_child(grid)
	
	# Back Button for character selection
	var back_btn = Button.new()
	back_btn.text = "Back to Menu"
	back_btn.custom_minimum_size = Vector2(200, 50)
	back_btn.pressed.connect(func(): 
		character_panel.visible = false
		main_menu.visible = true
	)
	char_vbox.add_child(back_btn)
	char_vbox.move_child(back_btn, char_vbox.get_child_count()) # Ensure it's at the bottom
	
	# Populate Character Grid
	for char_data in UpgradeDB.CHARACTERS:
		var btn = Button.new()
		btn.text = "%s\n\n%s" % [char_data.name, char_data.description]
		btn.custom_minimum_size = Vector2(250, 300)
		btn.pressed.connect(func(): _on_character_selected(char_data.id))
		
		# Add icon if exists
		if FileAccess.file_exists(char_data.icon):
			var icon = TextureRect.new()
			icon.texture = load(char_data.icon)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.custom_minimum_size = Vector2(100, 100)
			icon.position = Vector2(75, 50)
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			btn.add_child(icon)
			
		grid.add_child(btn)
	
	# Map Selection Panel
	map_panel = Control.new()
	map_panel.visible = false
	map_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(map_panel)
	
	var map_bg = ColorRect.new()
	map_bg.color = Color(0.05, 0.1, 0.05, 1.0) # Very dark green
	map_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_panel.add_child(map_bg)
	
	var map_center = CenterContainer.new()
	map_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_panel.add_child(map_center)
	
	var map_vbox = VBoxContainer.new()
	map_center.add_child(map_vbox)
	
	var map_title = Label.new()
	map_title.text = "Select Map"
	map_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_title.add_theme_font_size_override("font_size", 48)
	map_vbox.add_child(map_title)
	
	var map_spacer = Control.new()
	map_spacer.custom_minimum_size = Vector2(0, 40)
	map_vbox.add_child(map_spacer)
	
	var map_grid = GridContainer.new()
	map_grid.columns = 2
	map_grid.add_theme_constant_override("h_separation", 40)
	map_vbox.add_child(map_grid)
	
	# Define Maps
	var maps = [
		{
			"id": "forest",
			"name": "The Dark Forest",
			"description": "Where the monsters roam free."
		}
	]
	
	for map_data in maps:
		var btn = Button.new()
		btn.text = "%s\n\n%s" % [map_data.name, map_data.description]
		btn.custom_minimum_size = Vector2(300, 250)
		btn.pressed.connect(func(): _on_map_selected(map_data.id))
		map_grid.add_child(btn)

	# Back Button for map selection
	var map_back_btn = Button.new()
	map_back_btn.text = "Back to Characters"
	map_back_btn.custom_minimum_size = Vector2(200, 50)
	map_back_btn.pressed.connect(func(): 
		map_panel.visible = false
		character_panel.visible = true
	)
	map_vbox.add_child(map_back_btn)

func _on_character_selected(id: String):
	Global.selected_character = id
	character_panel.visible = false
	map_panel.visible = true

func _on_map_selected(id: String):
	Global.selected_map = id
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _setup_upgrades_ui():
	# 3. Create Panel
	var panel_width = 600
	var panel_height = 500
	upgrades_panel = Panel.new()
	upgrades_panel.visible = false
	upgrades_panel.size = Vector2(panel_width, panel_height)
	upgrades_panel.position = (get_viewport_rect().size - upgrades_panel.size) / 2
	add_child(upgrades_panel)
	
	# Title
	var title = Label.new()
	title.text = "Permanent Upgrades"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 10)
	title.size = Vector2(panel_width, 30)
	title.add_theme_font_size_override("font_size", 24)
	upgrades_panel.add_child(title)
	
	# Gold Display
	gold_display = Label.new()
	gold_display.position = Vector2(25, 55)
	gold_display.add_theme_font_size_override("font_size", 18)
	gold_display.add_theme_color_override("font_color", Color.GOLD)
	upgrades_panel.add_child(gold_display)

	# Disable All Button
	var disable_all_btn = Button.new()
	disable_all_btn.text = "Disable All"
	disable_all_btn.position = Vector2(450, 50)
	disable_all_btn.size = Vector2(120, 35)
	disable_all_btn.pressed.connect(_on_disable_all_pressed)
	upgrades_panel.add_child(disable_all_btn)
	
	# Scroll Container for Upgrades
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(10, 100)
	scroll.size = Vector2(panel_width - 20, panel_height - 160)
	upgrades_panel.add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.name = "UpgradeList"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(vbox)
	
	# Close Button
	var close = Button.new()
	close.text = "Close"
	close.position = Vector2((panel_width - 120) / 2.0, panel_height - 50)
	close.size = Vector2(120, 40)
	close.pressed.connect(func(): upgrades_panel.visible = false)
	upgrades_panel.add_child(close)
	
	# Upgrade Rows
	_create_upgrade_ui_rows(vbox)

func _register_upgrade(id: String, upgrade_name: String, base_cost: int, max_lvl: int, icon_path: String = "res://icon.svg"):
	upgrade_rows[id] = {
		"base": base_cost,
		"max": max_lvl,
		"name": upgrade_name,
		"icon": icon_path,
		"label": null,
		"buy_btn": null,
		"toggle_btn": null
	}

func _create_upgrade_ui_rows(parent_vbox: VBoxContainer):
	for id in upgrade_rows:
		var row = upgrade_rows[id]
		var h_box = HBoxContainer.new()
		h_box.custom_minimum_size = Vector2(0, 60)
		h_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		parent_vbox.add_child(h_box)
		
		# Spacer for padding
		var spacer_left = Control.new()
		spacer_left.custom_minimum_size = Vector2(15, 0)
		h_box.add_child(spacer_left)
		
		# Upgrade Icon
		var tex = TextureRect.new()
		var icon_p = row.icon
		if not FileAccess.file_exists(icon_p):
			icon_p = "res://icon.svg"
		tex.texture = load(icon_p)
		tex.custom_minimum_size = Vector2(40, 40)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h_box.add_child(tex)
		
		var label = Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		h_box.add_child(label)
		row.label = label
		
		var buy_btn = Button.new()
		buy_btn.custom_minimum_size = Vector2(140, 45)
		h_box.add_child(buy_btn)
		row.buy_btn = buy_btn
		buy_btn.pressed.connect(func(): _try_buy_upgrade(id))
		
		var toggle_btn = Button.new()
		toggle_btn.custom_minimum_size = Vector2(110, 45)
		h_box.add_child(toggle_btn)
		row.toggle_btn = toggle_btn
		toggle_btn.pressed.connect(func(): _toggle_upgrade_disabled(id))
		
		# Spacer for padding
		var spacer_right = Control.new()
		spacer_right.custom_minimum_size = Vector2(15, 0)
		h_box.add_child(spacer_right)

func _on_disable_all_pressed():
	var disabled = Global.save_data.get("disabled_upgrades", [])
	# If anything is enabled, disable everything. If everything is already disabled, enable all?
	# Let's just make it "Disable All" as requested.
	for id in upgrade_rows:
		if id not in disabled:
			disabled.append(id)
	Global.save_data["disabled_upgrades"] = disabled
	Global.save_game()
	_update_upgrades_ui()

func _toggle_upgrade_disabled(id: String):
	var disabled = Global.save_data.get("disabled_upgrades", [])
	if id in disabled:
		disabled.erase(id)
	else:
		disabled.append(id)
	Global.save_data["disabled_upgrades"] = disabled
	Global.save_game()
	_update_upgrades_ui()

func _open_upgrades_panel():
	upgrades_panel.visible = true
	_update_upgrades_ui()

func _update_upgrades_ui():
	gold_display.text = "Gold: %d" % Global.save_data.gold
	var disabled = Global.save_data.get("disabled_upgrades", [])
	
	for id in upgrade_rows:
		var row = upgrade_rows[id]
		var lvl = Global.save_data.upgrades[id]
		var cost = row.base * (lvl + 1)
		
		row.label.text = "%s\nLvl: %d / %d" % [row.name, lvl, row.max]
		
		if lvl >= row.max:
			row.buy_btn.text = "MAXED"
			row.buy_btn.disabled = true
		else:
			row.buy_btn.text = "Buy (%d G)" % cost
			row.buy_btn.disabled = Global.save_data.gold < cost
			
		if id in disabled:
			row.toggle_btn.text = "Disabled"
			row.toggle_btn.modulate = Color.RED
			row.label.modulate = Color(0.5, 0.5, 0.5, 1.0)
		else:
			row.toggle_btn.text = "Enabled"
			row.toggle_btn.modulate = Color.GREEN
			row.label.modulate = Color.WHITE

func _try_buy_upgrade(id: String):
	var row = upgrade_rows[id]
	var lvl = Global.save_data.upgrades[id]
	if lvl >= row.max: return
	
	var cost = row.base * (lvl + 1)
	if Global.save_data.gold >= cost:
		Global.save_data.gold -= cost
		Global.save_data.upgrades[id] += 1
		Global.save_game()
		Global.console_log("Bought %s upgrade lvl %d" % [id, lvl + 1])
		_update_upgrades_ui()

func _on_start_button_pressed():
	main_menu.visible = false
	character_panel.visible = true

func _on_quit_button_pressed():
	get_tree().quit()

func _on_settings_button_pressed():
	settings_panel.visible = true

func _on_back_button_pressed():
	settings_panel.visible = false

func _on_debug_check_toggled(toggled_on):
	Global.debug_enabled = toggled_on

func _on_cheats_check_toggled(toggled_on):
	Global.cheats_enabled = toggled_on

func _on_fps_check_toggled(toggled_on):
	Global.fps_enabled = toggled_on

func _on_dps_check_toggled(toggled_on):
	Global.dps_enabled = toggled_on

func _on_ff_check_toggled(toggled_on):
	Global.fast_forward_button_enabled = toggled_on
	Global.save_data.fast_forward_button_enabled = toggled_on
	Global.save_game()

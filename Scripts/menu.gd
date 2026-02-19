extends Control

@onready var settings_panel = $SettingsPanel
@onready var debug_check = $SettingsPanel/VBoxContainer/DebugCheck
@onready var cheats_check = $SettingsPanel/VBoxContainer/CheatsCheck
@onready var fps_check = $SettingsPanel/VBoxContainer/FPSCheck
@onready var dps_check = $SettingsPanel/VBoxContainer/DPSCheck

var upgrades_panel: Panel
var gold_display: Label
var upgrade_rows = {}

func _ready():
	# Load current state
	debug_check.button_pressed = Global.debug_enabled
	cheats_check.button_pressed = Global.cheats_enabled
	fps_check.button_pressed = Global.fps_enabled
	dps_check.button_pressed = Global.dps_enabled
	
	# 1. Create Upgrades Button (Main Menu)
	var btn = Button.new()
	btn.text = "Upgrades"
	btn.position = Vector2(50, 300) # Adjust as needed
	btn.size = Vector2(200, 50)
	btn.pressed.connect(func(): _open_upgrades_panel())
	add_child(btn)

	# 2. Register Upgrades (ensure they exist in row registry before UI init)
	_register_upgrade("health", "Max Health (+10)", 100, 5, "res://Sprites/Helth.png")
	_register_upgrade("damage", "Damage (+5%)", 150, 5, "res://Sprites/Icon24.png")
	_register_upgrade("speed", "Speed (+20)", 120, 3, "res://Sprites/Boots.png")
	_register_upgrade("regeneration", "HP Regen (+0.5/s)", 200, 3, "res://Sprites/regeneration (2).png")
	_register_upgrade("gold_gain", "Gold Drops (+100%)", 10000, 3, "res://Sprites/gold;.png")
	_register_upgrade("attack_speed", "Attack Speed (+15%)", 500, 3, "res://Sprites/wepons/dagger.png")
	_register_upgrade("defense", "Defense (+1)", 250, 5, "res://Sprites/Shield.png")

	_setup_upgrades_ui()

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
	close.position = Vector2((panel_width - 120) / 2, panel_height - 50)
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
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

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

extends Control

@onready var settings_panel = $SettingsPanel
@onready var debug_check = $SettingsPanel/VBoxContainer/DebugCheck
@onready var cheats_check = $SettingsPanel/VBoxContainer/CheatsCheck
@onready var fps_check = $SettingsPanel/VBoxContainer/FPSCheck

var upgrades_panel: Panel
var gold_display: Label
var upgrade_rows = {}

func _ready():
	# Load current state
	debug_check.button_pressed = Global.debug_enabled
	cheats_check.button_pressed = Global.cheats_enabled
	fps_check.button_pressed = Global.fps_enabled
	
	_setup_upgrades_ui()

func _setup_upgrades_ui():
	# 1. Create Upgrades Button
	var btn = Button.new()
	btn.text = "Upgrades"
	btn.position = Vector2(50, 300) # Adjust as needed
	btn.size = Vector2(200, 50)
	btn.pressed.connect(func(): _open_upgrades_panel())
	add_child(btn)
	
	# 2. Create Panel
	upgrades_panel = Panel.new()
	upgrades_panel.visible = false
	upgrades_panel.size = Vector2(400, 400)
	upgrades_panel.position = Vector2((get_viewport_rect().size.x - 400)/2, (get_viewport_rect().size.y - 400)/2)
	add_child(upgrades_panel)
	
	# Title
	var title = Label.new()
	title.text = "Permanent Upgrades"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 10)
	title.size = Vector2(400, 30)
	upgrades_panel.add_child(title)
	
	# Gold Display
	gold_display = Label.new()
	gold_display.position = Vector2(20, 50)
	gold_display.add_theme_color_override("font_color", Color.GOLD)
	upgrades_panel.add_child(gold_display)
	
	# Close Button
	var close = Button.new()
	close.text = "Close"
	close.position = Vector2(150, 360)
	close.size = Vector2(100, 30)
	close.pressed.connect(func(): upgrades_panel.visible = false)
	upgrades_panel.add_child(close)
	
	# Upgrade Rows
	_create_upgrade_row("health", "Max Health (+10)", 100, 5, 80)
	_create_upgrade_row("damage", "Damage (+5%)", 150, 5, 130)
	_create_upgrade_row("speed", "Speed (+20)", 120, 3, 180)

func _create_upgrade_row(id: String, name: String, base_cost: int, max_lvl: int, y_pos: float):
	var container = Control.new()
	container.position = Vector2(20, y_pos)
	upgrades_panel.add_child(container)
	
	var label = Label.new()
	label.position = Vector2(0, 0)
	container.add_child(label)
	
	var buy_btn = Button.new()
	buy_btn.position = Vector2(200, 0)
	buy_btn.size = Vector2(140, 30)
	container.add_child(buy_btn)
	
	upgrade_rows[id] = {
		"label": label,
		"btn": buy_btn,
		"base": base_cost,
		"max": max_lvl,
		"name": name
	}
	
	buy_btn.pressed.connect(func(): _try_buy_upgrade(id))

func _open_upgrades_panel():
	upgrades_panel.visible = true
	_update_upgrades_ui()

func _update_upgrades_ui():
	gold_display.text = "Gold: %d" % Global.save_data.gold
	
	for id in upgrade_rows:
		var row = upgrade_rows[id]
		var lvl = Global.save_data.upgrades[id]
		var cost = row.base * (lvl + 1)
		
		row.label.text = "%s\nLvl: %d / %d" % [row.name, lvl, row.max]
		
		if lvl >= row.max:
			row.btn.text = "MAXED"
			row.btn.disabled = true
		else:
			row.btn.text = "Buy (%d G)" % cost
			row.btn.disabled = Global.save_data.gold < cost

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

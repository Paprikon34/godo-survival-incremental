extends Node2D

@export var enemy_scene: PackedScene
@export var fast_enemy_scene: PackedScene
@export var tank_enemy_scene: PackedScene
@export var elite_enemy_scene: PackedScene
@export var boss_scene: PackedScene
@export var boss_2_scene: PackedScene
@export var elite_boss_scene: PackedScene
@export var splitting_boss_scene: PackedScene
@export var splitting_enemy_scene: PackedScene

var WAVE_DATA = [
	{ "time": 0, "interval": 2.0, "enemies": ["basic"] },
	{ "time": 90, "type": "boss", "enemies": ["boss_1"] }, # Boss 1:30
	{ "time": 95, "interval": 1.5, "enemies": ["basic"] },
	{ "time": 120, "interval": 1.5, "enemies": ["basic", "fast"] }, # Fast at 2m
	{ "time": 180, "type": "boss", "enemies": ["boss_2"] }, # Boss 3m
	{ "time": 185, "interval": 1.2, "enemies": ["basic", "fast", "tank"] }, # Tank at 3m
	{ "time": 240, "type": "boss", "enemies": ["elite_boss"] }, # Boss 4m
	{ "time": 245, "interval": 1.0, "enemies": ["basic", "fast", "tank"] },
	{ "time": 300, "type": "boss", "enemies": ["splitting_boss"] }, # Boss 5m
	{ "time": 305, "interval": 0.8, "enemies": ["basic", "elite", "tank", "fast", "splitting_enemy"] } # Mix in lower HP enemies
]

var spawn_timer: float = 0.0
var boss_spawned_at = [] # Times we spawned a boss to avoid duplicates
var active_wave_data = null
var enemy_speed_multiplier: float = 1.0
var enemy_health_multiplier: float = 1.0
var screen_size: Vector2
var level_up_hp_bonus: float = 0.0
var level_ups_pending: int = 0
var active_bosses = []




@onready var label = $CanvasLayer/UI/Label
@onready var player = $Player

# New UI References
@onready var time_label = $CanvasLayer/UI/TimeLabel
var gold_label: Label
@onready var fps_label = $CanvasLayer/UI/FPSLabel
@onready var xp_bar = $CanvasLayer/UI/XPBar
@onready var pause_menu = $CanvasLayer/UI/PauseMenu
@onready var stats_panel = $CanvasLayer/UI/StatsPanel
@onready var stats_label = $CanvasLayer/UI/StatsPanel/StatsLabel
@onready var enemy_stats_panel = $CanvasLayer/UI/EnemyStatsPanel
@onready var enemy_stats_label = $CanvasLayer/UI/EnemyStatsPanel/StatsLabel
@onready var upgrade_list = $CanvasLayer/UI/UpgradeList
@onready var detailed_upgrade_list = $CanvasLayer/UI/DetailedUpgradeList
@onready var level_up_menu = $CanvasLayer/UI/LevelUpMenu
@onready var option_buttons = [
	$CanvasLayer/UI/LevelUpMenu/VBoxContainer/Option1,
	$CanvasLayer/UI/LevelUpMenu/VBoxContainer/Option2,
	$CanvasLayer/UI/LevelUpMenu/VBoxContainer/Option3,
	$CanvasLayer/UI/LevelUpMenu/VBoxContainer/Option4
]

var elapsed_time: float = 0.0
var current_upgrades = []
var upgrade_counts = {}

@onready var chest_popup = $CanvasLayer/UI/ChestRewardPopup
@onready var chest_reward_label = $CanvasLayer/UI/ChestRewardPopup/RewardLabel
@onready var chest_ok_button = $CanvasLayer/UI/ChestRewardPopup/OkButton
@onready var debug_console = $CanvasLayer/UI/DebugConsole
@onready var debug_log_label = $CanvasLayer/UI/DebugConsole/ScrollContainer/LogLabel
@onready var boss_bar_container = $CanvasLayer/UI/BossBarContainer
@onready var enemy_count_label = $CanvasLayer/UI/DebugConsole/EnemyCountLabel
@onready var cheat_menu = $CanvasLayer/UI/CheatMenu
@onready var god_button = $CanvasLayer/UI/CheatMenu/GodModeToggle
@onready var dmg_button = $CanvasLayer/UI/CheatMenu/SuperDamageToggle
@onready var reset_button = $CanvasLayer/UI/CheatMenu/ResetTimer

func _ready():
	screen_size = get_viewport_rect().size
	if player:
		player.level_up.connect(_on_level_up)
		player.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Create Gold Label dynamically
	gold_label = Label.new()
	gold_label.position = Vector2(100, 35) # Near timer
	gold_label.add_theme_font_size_override("font_size", 24)
	gold_label.add_theme_color_override("font_color", Color.GOLD)
	$CanvasLayer/UI.add_child(gold_label)
		
	if fps_label:
		fps_label.visible = Global.fps_enabled
	
	for i in range(option_buttons.size()):
		option_buttons[i].pressed.connect(_on_upgrade_selected.bind(i))
		
	chest_ok_button.pressed.connect(_on_chest_ok_pressed)
	
	# Debug Console Init
	debug_console.visible = Global.debug_enabled
	if Global.debug_enabled:
		Global.console_log_emitted.connect(_on_log_emitted)
		
	# Cheat Menu Init
	cheat_menu.visible = Global.cheats_enabled
	if Global.cheats_enabled:
		$CanvasLayer/UI/CheatMenu/SkipTime1.pressed.connect(_on_skip_time_1)
		$CanvasLayer/UI/CheatMenu/SkipTime2.pressed.connect(_on_skip_time_2)
		$CanvasLayer/UI/CheatMenu/SkipTime3.pressed.connect(_on_skip_time_3)
		$CanvasLayer/UI/CheatMenu/SkipTime4.pressed.connect(_on_skip_time_4)
		$CanvasLayer/UI/CheatMenu/SkipTime5.pressed.connect(_on_skip_time_5)
		$CanvasLayer/UI/CheatMenu/SkipTime6.pressed.connect(_on_skip_time_6)
		$CanvasLayer/UI/CheatMenu/SkipTime7.pressed.connect(_on_skip_time_7)
		$CanvasLayer/UI/CheatMenu/SkipTime8.pressed.connect(_on_skip_time_8)
		$CanvasLayer/UI/CheatMenu/SkipTime9.pressed.connect(_on_skip_time_9)
		god_button.pressed.connect(_on_god_mode_toggle)
		dmg_button.pressed.connect(_on_super_damage_toggle)
		$CanvasLayer/UI/CheatMenu/ResetTimer.pressed.connect(_on_reset_timer)
		$CanvasLayer/UI/CheatMenu/ForceSpawn.pressed.connect(_on_force_spawn)
		Global.console_log("CHEATS ENABLED!")
		
	level_up_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	stats_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	detailed_upgrade_list.process_mode = Node.PROCESS_MODE_ALWAYS
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_level_up():
	level_ups_pending += 1
	if level_up_menu.visible:
		return
		
	_show_level_up_menu()

func _show_level_up_menu():
	get_tree().paused = true
	
	# Increase enemy base difficulty
	level_up_hp_bonus += 0.5
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		var scaling = 1.0
		if "stats" in enemy and enemy.stats:
			scaling = enemy.stats.hp_scaling
		
		var bonus = 0.5 * scaling
		if "health" in enemy:
			enemy.health += bonus
		if "max_health" in enemy:
			enemy.max_health += bonus
	Global.console_log("Level Up! Enemies gain base +0.5 HP (scaled by type). Total base bonus: +" + str(level_up_hp_bonus))
	
	var num_choices = 3
	var luck_chance = 0.05 + (player.luck_multiplier - 1.0)
	if player and randf() < luck_chance:
		num_choices = 4
		Global.console_log("Lucky! Extra upgrade choice.")
		
	var options = UpgradeDB.get_random_upgrades(num_choices)
	current_upgrades = options
	
	level_up_menu.visible = true
	set_ui_state_paused(true)
	
	for i in range(option_buttons.size()):
		if i < options.size():
			option_buttons[i].visible = true
			var id = options[i].id
			var current_lvl = upgrade_counts.get(id, 0)
			var next_lvl = current_lvl + 1
			if id == "heal":
				option_buttons[i].text = "%s: %s" % [options[i].name, options[i].description]
			else:
				option_buttons[i].text = "%s (Lvl %d): %s" % [options[i].name, next_lvl, options[i].description]
		else:
			option_buttons[i].visible = false

func _on_upgrade_selected(index: int):
	if index < current_upgrades.size():
		var upgrade = current_upgrades[index]
		UpgradeDB.apply_upgrade(player, upgrade.id)
		
		# Track upgrade level
		var id = upgrade.id
		if id in upgrade_counts:
			upgrade_counts[id] += 1
		else:
			upgrade_counts[id] = 1
			
		update_upgrade_list_ui()
		update_detailed_upgrade_list()
		
		Global.console_log("Upgrade selected: " + id)
		
	level_ups_pending -= 1
	
	if level_ups_pending > 0:
		_show_level_up_menu()
	else:
		level_up_menu.visible = false
		get_tree().paused = false
		set_ui_state_paused(false)

func update_upgrade_list_ui():
	# Clear current list
	for child in upgrade_list.get_children():
		child.queue_free()
		
	# Rebuild list
	for id in upgrade_counts:
		if id == "heal": continue
		
		var lvl = upgrade_counts[id]
		# Find name from DB
		var label_text = id + " lvl " + str(lvl)
		
		for u in UpgradeDB.UPGRADES:
			if u.id == id:
				label_text = "%s lvl %d" % [u.name, lvl]
				break
				
		var l = Label.new()
		l.text = label_text
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		upgrade_list.add_child(l)

func update_detailed_upgrade_list():
	for child in detailed_upgrade_list.get_children():
		child.queue_free()
		
	for id in upgrade_counts:
		if id == "heal": continue
		
		var lvl = upgrade_counts[id]
		var u_data = null
		for u in UpgradeDB.UPGRADES:
			if u.id == id:
				u_data = u
				break
		
		if not u_data: continue
		
		var desc = ""
		match id:
			"magic_shotgun": desc = "+%d Projectiles" % [lvl]
			"smart": desc = "+%d%% XP Gain" % [lvl * 10]
			"speed": desc = "+%d%% Move Speed" % [lvl * 10]
			"damage": desc = "+%d%% Damage" % [lvl * 10]
			"challenge": desc = "+%d%% Enemies, +%d%% XP" % [lvl * 5, lvl * 10]
			"wand": desc = "-%d%% Cooldown" % [lvl * 10]
			"vitality": desc = "+%d%% Max HP" % [lvl * 10]
			"luck": desc = "+%d%% Luck" % [lvl * 10]
			_: desc = "Lvl %d" % [lvl]
		
		var l = Label.new()
		l.text = "%s lvl %d: %s" % [u_data.name, lvl, desc]
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		detailed_upgrade_list.add_child(l)

func on_chest_collected():
	Global.console_log("Chest collected!")
	# Get list of existing upgrades (excluding heal)
	var available_upgrades = []
	for id in upgrade_counts:
		if id != "heal":
			available_upgrades.append(id)
			
	if available_upgrades.size() > 0:
		var num_rewards = 1
		var luck_chance = 0.05 + (player.luck_multiplier - 1.0)
		var roll = randf()
		
		if roll < luck_chance * 0.2:
			num_rewards = 3
		elif roll < luck_chance:
			num_rewards = 2
			
		if num_rewards > 1:
			Global.console_log("Lucky! Chest contains %d rewards." % num_rewards)
			
		# Gold Reward Logic
		var base_gold_options = [100, 150, 200, 250, 500]
		# Luck influences chance for better gold
		var gold_roll = randf()
		var gold_idx = 0
		
		# Simple weighted logic influenced by luck
		var luck_factor = player.luck_multiplier
		if gold_roll < 0.05 * luck_factor: gold_idx = 4 # 500
		elif gold_roll < 0.15 * luck_factor: gold_idx = 3 # 250
		elif gold_roll < 0.3 * luck_factor: gold_idx = 2 # 200
		elif gold_roll < 0.5 * luck_factor: gold_idx = 1 # 150
		else: gold_idx = 0 # 100
		
		var gold_amount = base_gold_options[gold_idx]
		
		# Multiplier applies to gold too
		if num_rewards == 3: gold_amount *= 3
		elif num_rewards == 2: gold_amount *= 2
		
		Global.add_gold(gold_amount)
			
		var reward_text = "Reward:\nGold: +%d\n" % gold_amount
		for i in range(num_rewards):
			var random_id = available_upgrades.pick_random()
			UpgradeDB.apply_upgrade(player, random_id)
			upgrade_counts[random_id] = upgrade_counts.get(random_id, 0) + 1
			reward_text += "%s +1 Level\n" % random_id.capitalize()
		
		# Update UIs
		update_upgrade_list_ui()
		update_detailed_upgrade_list()
		
		# Show Popup
		get_tree().paused = true
		chest_reward_label.text = reward_text
		chest_popup.visible = true
	else:
		# Fallback if maxed or no upgrades? (Rare logic, but safe to just print)
		Global.console_log("No valid upgrades for chest.")

func _on_chest_ok_pressed():
	chest_popup.visible = false
	get_tree().paused = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = not get_tree().paused
	pause_menu.visible = get_tree().paused
	set_ui_state_paused(get_tree().paused)
	if pause_menu.visible and player:
		update_stats_label()

func set_ui_state_paused(is_paused: bool):
	stats_panel.visible = is_paused
	enemy_stats_panel.visible = is_paused
	detailed_upgrade_list.visible = is_paused
	upgrade_list.visible = not is_paused
	if is_paused:
		update_stats_label()
		update_enemy_stats_label()
		update_detailed_upgrade_list()

func update_enemy_stats_label():
	if enemy_stats_label:
		# Calculate percentage increase (e.g., 1.0 -> +0%, 1.1 -> +10%)
		var speed_pct = int((enemy_speed_multiplier - 1.0) * 100)
		var hp_pct = int((enemy_health_multiplier - 1.0) * 100)
		
		enemy_stats_label.text = "Enemy Stats:\nMove Speed: +%d%%\nHP: +%d%%\nLvl HP: +%.1f" % [
			speed_pct,
			hp_pct,
			level_up_hp_bonus
		]

func update_stats_label():
	if stats_label:
		# Convert multipliers to percentages (e.g., 1.1 -> 110%)
		var dmg_pct = int(player.damage_multiplier * 100)
		var xp_pct = int(player.xp_multiplier * 100)
		var luck_pct = int(player.luck_multiplier * 100)
		
		stats_label.text = "Player Stats:\nLvl: %d\nHP: %d/%d\nSpeed: %d\nDamage: %d%%\nXP Gain: %d%%\nLuck: %d%%" % [
			player.level,
			player.health,
			player.max_health,
			player.speed,
			dmg_pct,
			xp_pct,
			luck_pct
		]

func _on_resume_pressed():
	toggle_pause()

func _on_quit_pressed():
	toggle_pause() # Unpause before leaving
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _process(delta):
	# If paused, don't run game logic (spawning, timers)
	if get_tree().paused:
		return
		
	if fps_label.visible:
		var fps = Engine.get_frames_per_second()
		fps_label.text = "FPS: %d" % fps
		if fps > 55:
			fps_label.modulate = Color.GREEN
		elif fps < 25:
			fps_label.modulate = Color.RED
		else:
			fps_label.modulate = Color.YELLOW
		
	elapsed_time += delta
	spawn_timer += delta
		
	# 1. Wave Switching (Dictionary based)
	var best_wave = null
	for wave in WAVE_DATA:
		if elapsed_time >= wave.time:
			best_wave = wave
	
	if active_wave_data != best_wave:
		active_wave_data = best_wave
		Global.console_log("WAVE CHANGED. Time: " + str(active_wave_data.time))
		
		# Boss Check (One-shot)
		if active_wave_data.get("type") == "boss":
			if not boss_spawned_at.has(active_wave_data.time):
				boss_spawned_at.append(active_wave_data.time)
				var type = active_wave_data.enemies[0]
				spawn_enemy_by_type(type)

	# 2. Spawning Logic (Standard enemies)
	if active_wave_data and active_wave_data.get("type") != "boss":
		var interval = active_wave_data.get("interval", 2.0)
		if spawn_timer >= interval:
			spawn_timer = 0.0
			var type = active_wave_data.enemies.pick_random()
			spawn_enemy_by_type(type)
	
	# 2.5 Minimum Density Check (Enforcement)
	var min_enemies = 5 # Active from the start (0-1 min)
	
	# Only enforce if we have an active wave to pick enemies from
	if active_wave_data and active_wave_data.has("enemies"):
		var current_enemies = get_tree().get_nodes_in_group("enemy").size()
		if current_enemies < min_enemies:
			var to_spawn = min_enemies - current_enemies
			for i in range(to_spawn):
				var type = active_wave_data.enemies.pick_random()
				spawn_enemy_by_type(type)
	
	# 3. UI Update Safety
	if not time_label:
		return

	var minutes = int(elapsed_time / 60)
	var seconds = int(elapsed_time) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
	
	if gold_label:
		gold_label.text = "Gold: %d" % Global.save_data.gold
	
	if player:
		# XP Bar is 0 to 100% of current level requirement
		# Since level up threshold is level * 80
		var required_xp = player.level * 80
		xp_bar.max_value = required_xp
		xp_bar.value = player.experience
		
		# Keep debug label for stats
		label.text = "HP: %d | Lvl: %d" % [player.health, player.level]

	# Boss Bar Logic
	if active_bosses.size() > 0:
		active_bosses = active_bosses.filter(func(e): return is_instance_valid(e))
	
	for child in boss_bar_container.get_children():
		child.queue_free()
		
	if active_bosses.size() > 0:
		boss_bar_container.visible = true
		for boss in active_bosses:
			var bar_panel = Panel.new()
			bar_panel.custom_minimum_size = Vector2(0, 25)
			boss_bar_container.add_child(bar_panel)
			
			var bar = ProgressBar.new()
			bar.modulate = Color(1, 0, 0, 1)
			bar.show_percentage = false
			bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			if "max_health" in boss:
				bar.max_value = boss.max_health
			if "health" in boss:
				bar.value = boss.health
			bar_panel.add_child(bar)
			
			var name_label = Label.new()
			name_label.text = "BOSS"
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			name_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			name_label.add_theme_font_size_override("font_size", 12)
			name_label.add_theme_constant_override("outline_size", 4)
			name_label.add_theme_color_override("font_outline_color", Color(0,0,0,1))
			bar_panel.add_child(name_label)
	else:
		boss_bar_container.visible = false

	# Performance: Enemy Culling & Debug Info
	var all_enemies = get_tree().get_nodes_in_group("enemy")
	if Global.debug_enabled and enemy_count_label:
		enemy_count_label.text = "Enemies: %d" % all_enemies.size()
	
	# Cull distant enemies (every N frames or every frame if small count)
	for enemy in all_enemies:
		if not is_instance_valid(enemy): continue
		if enemy in active_bosses: continue # Don't cull bosses!
		
		var dist_sq = player.global_position.distance_squared_to(enemy.global_position)
		if dist_sq > 4000000: # 2000px squared (keeping it tighter than 3000 to be safe)
			enemy.queue_free()




func add_active_boss(boss: Node2D):
	if not active_bosses.has(boss):
		active_bosses.append(boss)
		if not boss.is_connected("tree_exited", _on_boss_tree_exited):
			boss.tree_exited.connect(_on_boss_tree_exited.bind(boss))
		Global.console_log("BOSS REGISTERED!")

func _on_boss_tree_exited(boss):
	active_bosses.erase(boss)
	Global.console_log("BOSS DEFEATED/REMOVED")

func update_all_enemies():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if "speed" in enemy:
			# Give them a 5% boost to match the upgrade
			enemy.speed *= 1.05
		if "health" in enemy:
			enemy.health *= 1.05
		if "max_health" in enemy:
			enemy.max_health *= 1.05
	Global.console_log("Instant Buff: All current enemies speed/HP increased by 5%!")

func spawn_enemy_by_type(type: String):
	var scene: PackedScene = null
	var is_boss: bool = false
	var enemy_name: String = "Enemy"
	var stats_path: String = ""
	
	match type:
		"basic": 
			scene = enemy_scene
			enemy_name = "Basic Enemy"
			stats_path = "res://Resources/Data/Enemies/basic_enemy.tres"
		"fast": 
			scene = fast_enemy_scene
			enemy_name = "Fast Enemy"
			stats_path = "res://Resources/Data/Enemies/fast_enemy.tres"
		"tank": 
			scene = tank_enemy_scene
			enemy_name = "Tank Enemy"
			stats_path = "res://Resources/Data/Enemies/tank_enemy.tres"
		"elite": 
			scene = elite_enemy_scene
			enemy_name = "Elite Enemy"
			stats_path = "res://Resources/Data/Enemies/elite_enemy.tres"
		"boss_1": 
			scene = boss_scene
			is_boss = true
			enemy_name = "Boss I"
			stats_path = "res://Resources/Data/Bosses/boss_1_data.tres"
		"boss_2": 
			scene = boss_2_scene
			if not scene: scene = boss_scene # Fallback to boss 1 scene
			is_boss = true
			enemy_name = "Boss II"
			stats_path = "res://Resources/Data/Bosses/boss_2_data.tres"
		"elite_boss": 
			scene = elite_boss_scene
			if not scene: scene = boss_scene
			is_boss = true
			enemy_name = "Elite Boss"
			stats_path = "res://Resources/Data/Bosses/elite_boss_data.tres"
		"splitting_boss": 
			scene = splitting_boss_scene
			is_boss = true
			enemy_name = "Void Splitter"
			stats_path = "res://Resources/Data/Bosses/splitting_boss_data.tres"
		"splitting_enemy":
			scene = splitting_enemy_scene
			enemy_name = "Splitting Enemy"
			stats_path = "res://Resources/Data/Enemies/splitting_enemy.tres"

	if not scene: 
		Global.console_log("Error: Scene not found for type " + type)
		return
		
	var enemy = scene.instantiate()
	enemy.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Visually distinguish Elite enemies
	if type == "elite":
		enemy.modulate = Color(1.0, 0.4, 0.4) # Reddish tint
	
	# Load and assign stats if available
	if stats_path != "" and FileAccess.file_exists(stats_path):
		var s = load(stats_path)
		if s:
			enemy.set("stats", s)
	
	# Apply multipliers via properties (applied in enemy's _ready)
	var scaling = 1.0
	var stats = enemy.get("stats")
	if stats:
		scaling = stats.hp_scaling
		
	enemy.extra_hp = level_up_hp_bonus * scaling
	enemy.hp_mult = enemy_health_multiplier
	enemy.speed_mult = enemy_speed_multiplier
	
	# Spawn location (Just outside the screen boundary)
	var angle = randf() * PI * 2
	var radius = (screen_size.length() / 2.0) + 100.0 # Just beyond the furthest corner
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * radius
	
	enemy.global_position = spawn_pos
	add_child(enemy)
	
	if is_boss:
		add_active_boss(enemy)
		Global.console_log("BOSS SPAWNED: " + enemy_name)
	else:
		Global.console_log("Spawned " + enemy_name)

@warning_ignore("unused_parameter")
func spawn_from_wave(wave: Resource):
	Global.console_log("Error: spawn_from_wave called (DEPRECATED)")

func _on_log_emitted(text: String):
	if debug_log_label:
		debug_log_label.text += "\n" + text

# --- Cheat Functions ---

func _on_skip_time_1():
	elapsed_time = 89.0
	Global.console_log("Cheat: Skipped to 1:29")

func _on_skip_time_2():
	elapsed_time = 179.0
	Global.console_log("Cheat: Skipped to 2:59")

func _on_skip_time_3():
	elapsed_time = 239.0
	Global.console_log("Cheat: Skipped to 3:59")

func _on_skip_time_4():
	elapsed_time = 299.0
	Global.console_log("Cheat: Skipped to 4:59")

func _on_skip_time_5():
	elapsed_time = 359.0
	Global.console_log("Cheat: Skipped to 5:59")

func _on_skip_time_6():
	elapsed_time = 419.0
	Global.console_log("Cheat: Skipped to 6:59")

func _on_skip_time_7():
	elapsed_time = 479.0
	Global.console_log("Cheat: Skipped to 7:59")

func _on_skip_time_8():
	elapsed_time = 539.0
	Global.console_log("Cheat: Skipped to 8:59")

func _on_skip_time_9():
	elapsed_time = 599.0
	Global.console_log("Cheat: Skipped to 9:59")

func _on_god_mode_toggle():
	player.is_god_mode = not player.is_god_mode
	god_button.text = "God Mode: " + ("ON" if player.is_god_mode else "OFF")
	Global.console_log("Cheat: God Mode " + god_button.text)

func _on_super_damage_toggle():
	if player.damage_multiplier < 900.0:
		player.damage_multiplier = 1000.0
		dmg_button.text = "Super Damage: ON"
	else:
		player.damage_multiplier = 1.0
		dmg_button.text = "Super Damage: OFF"
	Global.console_log("Cheat: " + dmg_button.text)

func _on_reset_timer():
	elapsed_time = 0.0
	spawn_timer = 0.0
	active_wave_data = null
	Global.console_log("Cheat: Timer Reset")

func _on_force_spawn():
	if active_wave_data:
		Global.console_log("Manual Spawn Triggered")
		var type = active_wave_data.enemies.pick_random()
		spawn_enemy_by_type(type)
	else:
		Global.console_log("Manual Spawn Failed: No active wave data!")

extends Node2D

@export var enemy_scene: PackedScene
@export var fast_enemy_scene: PackedScene
@export var boss_scene: PackedScene
@export var spawn_interval: float = 0.66

var enemy_speed_multiplier: float = 1.0
var enemy_health_multiplier: float = 1.0

var spawn_timer: float = 0.0
var screen_size: Vector2
var boss_spawned: bool = false
var boss_2_spawned: bool = false
var level_up_hp_bonus: float = 0.0




@onready var label = $CanvasLayer/UI/Label
@onready var player = $Player

# New UI References
@onready var time_label = $CanvasLayer/UI/TimeLabel
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

func _ready():
	screen_size = get_viewport_rect().size
	if player:
		player.level_up.connect(_on_level_up)
		player.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	for i in range(option_buttons.size()):
		option_buttons[i].pressed.connect(_on_upgrade_selected.bind(i))
		
	chest_ok_button.pressed.connect(_on_chest_ok_pressed)
	
	# Debug Console Init
	debug_console.visible = Global.debug_enabled
	if Global.debug_enabled:
		Global.log_emitted.connect(_on_log_emitted)
		
	level_up_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	stats_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	detailed_upgrade_list.process_mode = Node.PROCESS_MODE_ALWAYS
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_level_up():
	get_tree().paused = true
	
	# Increase enemy base difficulty
	level_up_hp_bonus += 0.5
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if "health" in enemy:
			enemy.health += 0.5
	Global.log("Level Up! Enemies gain +0.5 Max HP (Total bonus: +" + str(level_up_hp_bonus) + ")")
	
	var num_choices = 3
	var luck_chance = 0.05 + (player.luck_multiplier - 1.0)
	if player and randf() < luck_chance:
		num_choices = 4
		Global.log("Lucky! Extra upgrade choice.")
		
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
			"multishot": desc = "+%d Projectiles" % [lvl]
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
	Global.log("Chest collected!")
	# Get list of existing upgrades (excluding heal)
	var available_upgrades = []
	for id in upgrade_counts:
		if id != "heal":
			available_upgrades.append(id)
			
	if available_upgrades.size() > 0:
		var num_rewards = 1
		var luck_chance = 0.05 + (player.luck_multiplier - 1.0)
		if randf() < luck_chance:
			num_rewards = 2
		if randf() < luck_chance * 0.2:
			num_rewards = 3
			
		if num_rewards > 1:
			Global.log("Lucky! Chest contains %d rewards." % num_rewards)
			
		var reward_text = "Reward:\n"
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
		Global.log("No valid upgrades for chest.")

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
		
	elapsed_time += delta
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_enemy()
		
	# Boss Spawn Check
	if elapsed_time > 90.0 and not boss_spawned and boss_scene: # 1:30
		boss_spawned = true
		spawn_boss(1.0)
		
	if elapsed_time > 180.0 and not boss_2_spawned and boss_scene: # 3:00
		boss_2_spawned = true
		spawn_boss(3.0)
		Global.log("BOSS 2 SPAWNED!")
		
	# Update UI
	if not time_label: # Safety check if node not ready yet
		return

	var minutes = int(elapsed_time / 60)
	var seconds = int(elapsed_time) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
	
	if player:
		# XP Bar is 0 to 100% of current level requirement
		# Since level up threshold is level * 100
		var required_xp = player.level * 100
		xp_bar.max_value = required_xp
		xp_bar.value = player.experience
		
		# Keep debug label for stats
		label.text = "HP: %d | Lvl: %d" % [player.health, player.level]



func spawn_boss(health_mult: float = 1.0):
	# Note: We don't set boss_spawned here anymore to allow multiple calls, 
	# or we manage flags in _process. Let's just spawn it.
	var boss = boss_scene.instantiate()
	boss.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Apply global Despair multipliers
	if "speed" in boss:
		boss.speed *= enemy_speed_multiplier
	if "health" in boss:
		boss.health += level_up_hp_bonus
		boss.health *= enemy_health_multiplier
		
	# Apply specific Boss multiplier (e.g. 1.0 or 3.0)
	boss.health *= health_mult
	
	# Boss logic (spawn far away)
	var angle = randf() * PI * 2
	var radius = screen_size.length() / 1.5
	var spawn_pos = $Player.global_position + Vector2(cos(angle), sin(angle)) * radius
	
	boss.global_position = spawn_pos
	add_child(boss)
	Global.log("BOSS SPAWNED!")

func update_all_enemies():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if "speed" in enemy:
			# Give them a 5% boost to match the upgrade
			enemy.speed *= 1.05
		if "health" in enemy:
			enemy.health *= 1.05
	Global.log("Instant Buff: All current enemies speed/HP increased by 5%!")

func spawn_enemy():
	if not enemy_scene:
		return
		
	var chosen_scene = enemy_scene
	# Check if we should spawn fast enemy (after 2 mins = 120s)
	if elapsed_time > 120.0 and fast_enemy_scene:
		if randf() < 0.3: # 30% chance for fast enemy
			chosen_scene = fast_enemy_scene

	var enemy = chosen_scene.instantiate()
	enemy.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Apply multipliers
	if "speed" in enemy:
		enemy.speed *= enemy_speed_multiplier
	if "health" in enemy:
		enemy.health += level_up_hp_bonus
		enemy.health *= enemy_health_multiplier
	
	# Spawn outside the screen (simple logic)
	# Pick a random angle and a distance greater than half screen diagonal
	var angle = randf() * PI * 2
	var radius = screen_size.length() / 1.5
	var spawn_pos = $Player.global_position + Vector2(cos(angle), sin(angle)) * radius
	
	enemy.global_position = spawn_pos
	add_child(enemy)
	Global.log("Spawned Enemy (HP: " + str(enemy.health) + ")")

func _on_log_emitted(text: String):
	if debug_log_label:
		debug_log_label.text += "\n" + text

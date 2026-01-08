extends Node2D

@export var enemy_scene: PackedScene
@export var fast_enemy_scene: PackedScene
@export var spawn_interval: float = 1.0

var spawn_timer: float = 0.0
var screen_size: Vector2




@onready var label = $CanvasLayer/UI/Label
@onready var player = $Player

# New UI References
@onready var time_label = $CanvasLayer/UI/TimeLabel
@onready var xp_bar = $CanvasLayer/UI/XPBar
@onready var pause_menu = $CanvasLayer/UI/PauseMenu
@onready var level_up_menu = $CanvasLayer/UI/LevelUpMenu
@onready var option_buttons = [
	$CanvasLayer/UI/LevelUpMenu/VBoxContainer/Option1,
	$CanvasLayer/UI/LevelUpMenu/VBoxContainer/Option2,
	$CanvasLayer/UI/LevelUpMenu/VBoxContainer/Option3
]

var elapsed_time: float = 0.0
var current_upgrades = []

func _ready():
	screen_size = get_viewport_rect().size
	if player:
		player.level_up.connect(_on_level_up)

func _on_level_up():
	get_tree().paused = true
	var options = UpgradeDB.get_random_upgrades(3)
	current_upgrades = options
	
	level_up_menu.visible = true
	
	for i in range(3):
		if i < options.size():
			option_buttons[i].visible = true
			option_buttons[i].text = "%s: %s" % [options[i].name, options[i].description]
		else:
			option_buttons[i].visible = false

func _on_upgrade_selected(index: int):
	if index < current_upgrades.size():
		var upgrade = current_upgrades[index]
		UpgradeDB.apply_upgrade(player, upgrade.id)
		
	level_up_menu.visible = false
	get_tree().paused = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = not get_tree().paused
	pause_menu.visible = get_tree().paused

func _on_resume_pressed():
	toggle_pause()

func _on_quit_pressed():
	toggle_pause() # Unpause before leaving
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _process(delta):
	elapsed_time += delta
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_enemy()
		
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

func spawn_enemy():
	if not enemy_scene:
		return
		
	var chosen_scene = enemy_scene
	# Check if we should spawn fast enemy (after 3 mins = 180s)
	# For testing, let's use 10 seconds? No, user said 3 mins.
	# But for verification I might need to wait. I'll stick to 180 as requested.
	if elapsed_time > 180.0 and fast_enemy_scene:
		if randf() < 0.3: # 30% chance for fast enemy? Or just purely fast enemy? "start spawning" implies addition.
			chosen_scene = fast_enemy_scene

	var enemy = chosen_scene.instantiate()
	
	# Spawn outside the screen (simple logic)
	# Pick a random angle and a distance greater than half screen diagonal
	var angle = randf() * PI * 2
	var radius = screen_size.length() / 1.5
	var spawn_pos = $Player.global_position + Vector2(cos(angle), sin(angle)) * radius
	
	enemy.global_position = spawn_pos
	add_child(enemy)

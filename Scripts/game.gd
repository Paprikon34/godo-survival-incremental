extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 1.0

var spawn_timer: float = 0.0
var screen_size: Vector2

func _ready():
	screen_size = get_viewport_rect().size

@onready var label = $CanvasLayer/UI/Label
@onready var player = $Player

# New UI References
@onready var time_label = $CanvasLayer/UI/TimeLabel
@onready var xp_bar = $CanvasLayer/UI/XPBar
@onready var pause_menu = $CanvasLayer/UI/PauseMenu

var elapsed_time: float = 0.0

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
		
	var enemy = enemy_scene.instantiate()
	
	# Spawn outside the screen (simple logic)
	# Pick a random angle and a distance greater than half screen diagonal
	var angle = randf() * PI * 2
	var radius = screen_size.length() / 1.5
	var spawn_pos = $Player.global_position + Vector2(cos(angle), sin(angle)) * radius
	
	enemy.global_position = spawn_pos
	add_child(enemy)

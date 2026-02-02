extends Node2D

@export var boss_type: String = ""
var boss_node: Node2D = null

@onready var arena_bounds = $ArenaBounds
@onready var spawn_pos = $SpawnPos
@onready var player_pos = $PlayerPos

signal boss_defeated

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Arena must run while game world is disabled
	spawn_boss()

func spawn_boss():
	var boss_scene = null
	# Based on boss_type, we spawn a much cooler boss
	# For now, let's map existing boss types to enhanced versions
	match boss_type:
		"boss_1":
			boss_scene = load("res://Scenes/enhanced_boss_1.tscn")
		"boss_2":
			boss_scene = load("res://Scenes/enhanced_boss_2.tscn")
		"splitting_boss":
			boss_scene = load("res://Scenes/enhanced_splitting_boss.tscn")
		_:
			# Fallback to a basic boss if enhanced is missing
			boss_scene = load("res://Scenes/boss.tscn")
	
	if boss_scene:
		boss_node = boss_scene.instantiate()
		boss_node.global_position = spawn_pos.global_position
		boss_node.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(boss_node)
		
		# Set up special AI
		if boss_node.has_method("start_boss_fight"):
			boss_node.start_boss_fight()
			
		boss_node.tree_exited.connect(_on_boss_defeated)

func _on_boss_defeated():
	Global.console_log("Boss Arena: Boss Defeated!")
	boss_defeated.emit()
	# Spawn rewards and exit portal
	spawn_victory_rewards()

func spawn_victory_rewards():
	# Spawn a BIG chest in the center
	var chest = load("res://Scenes/chest.tscn").instantiate()
	chest.global_position = spawn_pos.global_position
	add_child(chest)
	
	# Spawn an exit portal after a short delay or when chest is opened
	await get_tree().create_timer(2.0).timeout
	var exit_portal = load("res://Scenes/exit_portal.tscn").instantiate()
	exit_portal.global_position = spawn_pos.global_position + Vector2(100, 0)
	add_child(exit_portal)

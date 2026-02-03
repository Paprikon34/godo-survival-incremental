extends Node2D

@export var boss_type: String = ""
var boss_node: Node2D = null
var last_boss_pos: Vector2 = Vector2.ZERO
var active_arena_bosses = []

@onready var arena_bounds = $ArenaBounds
@onready var spawn_pos = $SpawnPos
@onready var player_pos = $PlayerPos

signal boss_defeated

func _ready():
	last_boss_pos = spawn_pos.global_position
	spawn_boss()

func _process(_delta):
	# Keep track of the last active boss position
	for boss in active_arena_bosses:
		if is_instance_valid(boss):
			last_boss_pos = boss.global_position
			break

func spawn_boss():
	var boss_scene = null
	match boss_type:
		"boss_1":
			boss_scene = load("res://Scenes/enhanced_boss_1.tscn")
		"boss_2":
			boss_scene = load("res://Scenes/enhanced_boss_2.tscn")
		"splitting_boss":
			boss_scene = load("res://Scenes/enhanced_splitting_boss.tscn")
		_:
			boss_scene = load("res://Scenes/boss.tscn")
	
	if boss_scene:
		boss_node = boss_scene.instantiate()
		add_child(boss_node)
		boss_node.global_position = spawn_pos.global_position
		add_active_boss(boss_node)
		
		if boss_node.has_method("start_boss_fight"):
			boss_node.start_boss_fight()

# Called by splitting bosses to register their minis
func add_active_boss(boss: Node2D):
	if not active_arena_bosses.has(boss):
		active_arena_bosses.append(boss)
		boss.tree_exited.connect(_on_boss_defeated.bind(boss))
		
		# Also register with main game for UI/health bars
		var game = get_tree().get_first_node_in_group("game")
		if game and game.has_method("add_active_boss"):
			game.add_active_boss(boss)

func _on_boss_defeated(boss):
	active_arena_bosses.erase(boss)
	
	# Only spawn rewards when ALL bosses/minis in the arena are gone
	if active_arena_bosses.size() == 0:
		Global.console_log("Boss Arena: All boss entities defeated!")
		boss_defeated.emit()
		spawn_victory_rewards()

func spawn_victory_rewards():
	var spawn_at = last_boss_pos
	
	var chest = load("res://Scenes/chest.tscn").instantiate()
	chest.global_position = spawn_at
	add_child(chest)
	
	await get_tree().create_timer(2.0).timeout
	var exit_portal = load("res://Scenes/exit_portal.tscn").instantiate()
	exit_portal.global_position = spawn_at + Vector2(60, 0)
	add_child(exit_portal)

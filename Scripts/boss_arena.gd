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
	Global.console_log("Boss Arena: Boss entity defeated.")
	if active_arena_bosses.has(boss):
		active_arena_bosses.erase(boss)
	
	# Cleanup dead refs and filter
	var valid_bosses = []
	for b in active_arena_bosses:
		if is_instance_valid(b):
			valid_bosses.append(b)
	active_arena_bosses = valid_bosses
	
	Global.console_log("Boss Arena: Remaining boss entities: " + str(active_arena_bosses.size()))
	
	if active_arena_bosses.size() == 0:
		Global.console_log("Boss Arena: All boss entities gone. Spawning rewards...")
		boss_defeated.emit()
		spawn_victory_rewards()

func spawn_victory_rewards():
	# Use local position for easier logic relative to the arena
	var spawn_pos_local = Vector2.ZERO
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_node_or_null("Player") # Fallback if group fails
		
	if player:
		spawn_pos_local = player.position + Vector2(0, -80) # 80 pixels above player
		Global.console_log("Spawning rewards above player at local " + str(spawn_pos_local))
	else:
		# Fallback to local version of last boss pos
		spawn_pos_local = last_boss_pos - global_position
		Global.console_log("Player not found in arena! Spawning at fallback " + str(spawn_pos_local))
	
	var chest = load("res://Scenes/chest.tscn").instantiate()
	add_child(chest)
	chest.position = spawn_pos_local
	
	await get_tree().create_timer(1.5).timeout
	
	var exit_portal = load("res://Scenes/exit_portal.tscn").instantiate()
	add_child(exit_portal)
	exit_portal.position = spawn_pos_local + Vector2(100, 20) # Slightly offset
	Global.console_log("Exit portal spawned.")

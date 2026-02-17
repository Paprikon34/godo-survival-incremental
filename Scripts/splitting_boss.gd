extends "res://Scripts/enemy.gd"

var has_split: bool = false
@export var mini_boss_scene: PackedScene
@export var mini_boss_stats: EnemyData
@export var split_count: int = 4
@export var minis_are_bosses: bool = true

func take_damage(amount: float):
	super.take_damage(amount)
	
	if not has_split and health <= max_health * 0.5:
		has_split = true
		call_deferred("split")

func split():
	has_split = true
	Global.console_log("BOSS SPLITTING!")
	
	if mini_boss_scene:
		for i in range(split_count):
			var mini_instance = mini_boss_scene.instantiate()
			if mini_boss_stats:
				mini_instance.stats = mini_boss_stats
			var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
			mini_instance.process_mode = Node.PROCESS_MODE_PAUSABLE
			mini_instance.global_position = global_position + offset
			get_parent().add_child(mini_instance)
			
			# If game.gd tracks bosses, we should add to that too
			if minis_are_bosses and get_parent().has_method("add_active_boss"):
				get_parent().call("add_active_boss", mini_instance)
	
	queue_free()

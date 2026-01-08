extends Node2D

@export var damage: float = 10.0
@export var cooldown: float = 1.0
@export var projectile_speed: float = 400.0

var current_cooldown: float = 0.0

func _process(delta):
	current_cooldown -= delta
	if current_cooldown <= 0:
		var target = find_nearest_enemy()
		if target:
			fire(target)
			current_cooldown = cooldown

func find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		return null
		
	var nearest: Node2D = null
	var min_dist = INF
	
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy
			
	return nearest

func fire(target: Node2D):
	# Override in subclass
	pass

extends Node2D

@export var damage: float = 10.0
@export var cooldown: float = 1.0
@export var projectile_speed: float = 400.0

var current_cooldown: float = 0.0

func get_actual_cooldown() -> float:
	var player = get_parent()
	if player and "attack_speed_multiplier" in player:
		return cooldown / player.attack_speed_multiplier
	return cooldown

func _process(_delta):
	current_cooldown -= _delta
	if current_cooldown <= 0:
		var target = find_nearest_enemy()
		if target:
			fire(target)
			current_cooldown = get_actual_cooldown()

func find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		return null
		
	var nearest: Node2D = null
	var closest_dist = INF
	var max_range = 800.0
	var y_multiplier = 1.5 # Increase to decrease top/bottom range
	
	for enemy in enemies:
		# ONLY target enemies that are visible and active
		if not enemy.is_visible_in_tree() or enemy.process_mode == Node.PROCESS_MODE_DISABLED:
			continue
			
		var diff = enemy.global_position - global_position
		# Elliptical distance check: (x^2 + (y*mult)^2)
		var dist = sqrt(diff.x**2 + (diff.y * y_multiplier)**2)
		
		if dist < closest_dist and dist <= max_range:
			closest_dist = dist
			nearest = enemy
			
	return nearest

func fire(_target: Node2D):
	# Override in subclass
	pass

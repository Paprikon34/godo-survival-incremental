extends "res://Scripts/weapon_base.gd"

# Primary weapon: Magic Shotgun
# Fires multiple projectiles in a spread pattern.
const ProjectileScript = preload("res://Scripts/projectile.gd")

var projectile_count: int = 1

func fire(target: Node2D):
	for i in range(projectile_count):
		call_deferred("_spawn_projectile", target, i)

func _spawn_projectile(target: Node2D, index: int):
	if not is_instance_valid(target):
		return # Target might have died
		
	var projectile = Area2D.new()
	projectile.monitorable = false
	# Add components to projectile programmatically
	
	var sprite = Sprite2D.new()
	sprite.texture = load("res://icon.svg")
	sprite.scale = Vector2(0.3, 0.3)
	sprite.modulate = Color(0.2, 0.2, 1.0)
	projectile.add_child(sprite)
	
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 10
	collision.shape = shape
	projectile.add_child(collision)
	
	# Add script
	projectile.set_script(ProjectileScript)
	
	projectile.process_mode = Node.PROCESS_MODE_ALWAYS
	projectile.global_position = global_position
	
	# Apply spread if multiple
	var direction = (target.global_position - global_position).normalized()
	if projectile_count > 1:
		var spread_angle = 0.2 # Radians
		# Center is 0. Spread out.
		var angle_offset = (index - (projectile_count - 1) / 2.0) * spread_angle
		direction = direction.rotated(angle_offset)

	# Apply damage multiplier
	var player = get_parent()
	var dmg_mult = 1.0
	var pierce = 0
	if player:
		if "damage_multiplier" in player:
			dmg_mult = player.damage_multiplier
		if "piercing_count" in player:
			pierce = player.piercing_count

	projectile.set("direction", direction)
	projectile.set("speed", projectile_speed)
	projectile.set("damage", damage * dmg_mult)
	projectile.set("pierce_count", pierce)
	
	# Set projectile collision mask to 2 (Enemy layer)
	projectile.collision_mask = 2
	# Set projectile collision layer to 0 (don't get hit by things)
	projectile.collision_layer = 0
	
	get_tree().root.add_child(projectile)

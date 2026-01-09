extends "res://Scripts/weapon_base.gd"

func _init():
	damage = 15.0

# Fires a projectile towards the mouse position

const ProjectileScript = preload("res://Scripts/projectile.gd")

func fire(target: Node2D):
	# Override normal fire behavior
	# We want to fire at mouse, not nearest enemy
	pass

func _process(delta):
	current_cooldown -= delta
	if current_cooldown <= 0:
		# Wand auto-fires at mouse? Or should we wait for click?
		# Autoshooting at mouse is safer for survivors-like
		fire_at_mouse()
		current_cooldown = cooldown

func fire_at_mouse():
	var mouse_pos = get_global_mouse_position()
	
	var projectile = Area2D.new()
	# Optimization: We only need detection, not to be detected
	projectile.monitorable = false
	
	var sprite = Sprite2D.new()
	sprite.texture = load("res://icon.svg")
	sprite.scale = Vector2(0.2, 0.4)
	sprite.modulate = Color(0.5, 0.0, 1.0) # Purple
	projectile.add_child(sprite)
	
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 8
	collision.shape = shape
	projectile.add_child(collision)
	
	projectile.set_script(ProjectileScript)
	
	projectile.process_mode = Node.PROCESS_MODE_PAUSABLE
	projectile.global_position = global_position
	
	var direction = (mouse_pos - global_position).normalized()
	
	# Apply damage multiplier from player if possible
	var player = get_parent()
	var dmg_mult = 1.0
	var pierce = 0
	if player: 
		if "damage_multiplier" in player:
			dmg_mult = player.damage_multiplier
		if "piercing_count" in player:
			pierce = player.piercing_count
		
	projectile.set("direction", direction)
	projectile.set("speed", projectile_speed * 1.2)
	projectile.set("damage", damage * dmg_mult)
	projectile.set("pierce_count", pierce)
	projectile.collision_mask = 2
	projectile.collision_layer = 0
	
	get_tree().root.add_child(projectile)

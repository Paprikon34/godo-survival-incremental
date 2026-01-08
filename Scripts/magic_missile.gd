extends "res://Scripts/weapon_base.gd"

# We could use a packed scene for the projectile, but I'll draw it or make a simple node for now
const ProjectileScript = preload("res://Scripts/projectile.gd")

func fire(target: Node2D):
	var projectile = CharacterBody2D.new()
	# Add components to projectile programmatically for simplicity, or we could load a scene
	
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
	
	projectile.global_position = global_position
	
	# Set direction
	var direction = (target.global_position - global_position).normalized()
	projectile.set("direction", direction)
	projectile.set("speed", projectile_speed)
	projectile.set("damage", damage)
	
	# Set projectile collision mask to 2 (Enemy layer)
	projectile.collision_mask = 2
	# Set projectile collision layer to 0 (don't get hit by things)
	projectile.collision_layer = 0
	
	get_tree().root.add_child(projectile)

extends "res://Scripts/weapon_base.gd"

# Dagger Weapon: Fires in the direction the player is facing.
const DAGGER_PROJECTILE_SCENE = preload("res://Scenes/dagger_projectile.tscn")

func _ready():
	damage = 20.0
	cooldown = 0.8 # Slightly faster than base weapons
	projectile_speed = 600.0

func _process(_delta):
	current_cooldown -= _delta
	if current_cooldown <= 0:
		fire_forward()
		current_cooldown = cooldown

func fire_forward():
	var player = get_parent()
	var facing = Vector2.RIGHT
	if player and "last_facing_direction" in player:
		facing = player.last_facing_direction
	
	_spawn_dagger(facing)

func _spawn_dagger(direction: Vector2):
	var dagger = DAGGER_PROJECTILE_SCENE.instantiate()
	
	# Position at weapon/player center
	dagger.global_position = global_position
	
	# Apply damage multiplier
	var player = get_parent()
	var dmg_mult = 1.0
	if player and "damage_multiplier" in player:
		dmg_mult = player.damage_multiplier
	
	dagger.direction = direction
	dagger.speed = projectile_speed
	dagger.damage = damage * dmg_mult
	
	# Add to world parent to prevent following player
	get_tree().root.add_child(dagger)

extends "res://Scripts/weapon_base.gd"

# Sword Weapon: Swings in the direction the player is facing.
const SWORD_SWING_SCENE = preload("res://Scenes/sword_swing.tscn")

func _ready():
	damage = 25.0 # Higher damage since it's close range
	cooldown = 1.2
	
func _process(_delta):
	current_cooldown -= _delta
	if current_cooldown <= 0:
		fire_swing()
		current_cooldown = cooldown

func fire_swing():
	var player = get_parent()
	var facing = Vector2.RIGHT
	if player and "last_facing_direction" in player:
		facing = player.last_facing_direction
	
	_spawn_swing(facing)

func _spawn_swing(direction: Vector2):
	var swing = SWORD_SWING_SCENE.instantiate()
	
	# Position at weapon/player center
	swing.global_position = global_position
	
	# Orient the swing towards facing direction
	# The scene's "up" (-Y) is the tip of the sword, so we rotate +PI/2 to align it
	swing.rotation = direction.angle() + PI/2.0
	
	# Apply damage multiplier
	var player = get_parent()
	var dmg_mult = 1.0
	if player and "damage_multiplier" in player:
		dmg_mult = player.damage_multiplier
	
	swing.damage = damage * dmg_mult
	
	# Add to world parent but it should stay with player for the swing duration
	# Actually, usually swings are child of player but let's root it to be safe from player rotation
	# But we want it to follow player position. 
	# I'll add it as child of player (get_parent() is player)
	if player:
		player.add_child(swing)
		# Reset internal position to 0 since it's a child now
		swing.position = Vector2.ZERO

func upgrade():
	damage += 10.0
	cooldown *= 0.85

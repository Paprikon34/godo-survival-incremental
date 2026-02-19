extends CharacterBody2D

@export var stats: EnemyData
@export var speed: float = 100.0
@export var health: float = 10.0
@export var damage: float = 10.0
@export var drops_chest: bool = false
@export var drops_portal: bool = false
var portal_boss_type: String = ""
@export var xp_reward: float = 10.0
@export var defense: float = 0.0
@export var gold_reward: int = 1
@export var attack_interval: float = 0.5

var extra_hp: float = 0.0
var hp_mult: float = 1.0
var speed_mult: float = 1.0

var attack_timer: float = 0.0
var max_health: float = 10.0
var is_dead = false

@onready var player = get_tree().get_first_node_in_group("player")
@onready var hp_bar = get_node_or_null("HealthBar")
@onready var sprite = get_node_or_null("AnimatedSprite2D") if get_node_or_null("AnimatedSprite2D") else get_node_or_null("Sprite2D")
@onready var collision_shape = $CollisionShape2D

func _ready():
	if stats:
		health = stats.health
		max_health = stats.health
		speed = stats.speed
		damage = stats.damage
		defense = stats.defense
		xp_reward = stats.xp_reward
	
	# Apply Game-wide scaling
	health += extra_hp
	health *= hp_mult
	max_health = health
	speed *= speed_mult
	
	add_to_group("enemy")
	
	if sprite and sprite is AnimatedSprite2D:
		if sprite.sprite_frames.has_animation("move"):
			sprite.play("move")
		elif sprite.sprite_frames.has_animation("movment"):
			sprite.play("movment")
	
	if hp_bar:
		hp_bar.max_value = max_health
		hp_bar.value = health

func _physics_process(delta):
	if is_dead: return
	
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		
		if sprite:
			if direction.x < 0:
				sprite.flip_h = true
			elif direction.x > 0:
				sprite.flip_h = false
				
		move_and_slide()
		
		# Simple collision damage (if using CharacterBody2D collision)
		# Periodic collision damage
		if attack_timer > 0:
			attack_timer -= delta
		
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.has_method("take_damage") and collider.name == "Player":
				if attack_timer <= 0:
					collider.take_damage(damage) # Flat damage, not delta scaled
					attack_timer = attack_interval

func take_damage(amount: float):
	if is_dead: return
	
	var damage_taken = max(0.0, amount - defense)
	health -= damage_taken
	Global.damage_dealt.emit(damage_taken)
	if hp_bar:
		hp_bar.value = health
	# Global.console_log("Enemy took " + str(amount) + " damage. Remaining HP: " + str(health))
	if health <= 0:
		if drops_portal:
			call_deferred("_spawn_portal")
		elif drops_chest:
			call_deferred("_spawn_chest")
		die()

func _spawn_chest():
	var chest = preload("res://Scenes/chest.tscn").instantiate()
	chest.process_mode = Node.PROCESS_MODE_PAUSABLE
	chest.global_position = global_position
	get_parent().add_child(chest)

func _spawn_portal():
	# For now we use a placeholder or the chest scene if portal is missing
	var portal_scene_path = "res://Scenes/portal.tscn"
	var portal_scene
	if FileAccess.file_exists(portal_scene_path):
		portal_scene = load(portal_scene_path)
	else:
		# Fallback to a modified chest if portal scene doesn't exist yet
		portal_scene = preload("res://Scenes/chest.tscn")
		
	var portal = portal_scene.instantiate()
	portal.process_mode = Node.PROCESS_MODE_PAUSABLE
	portal.global_position = global_position
	if "boss_type" in portal:
		portal.boss_type = portal_boss_type
	
	# If we use chest as fallback, we might need to change its script or behavior
	# But for now, let's assume portal.tscn will be created.
	get_parent().add_child(portal)

func die():
	if is_dead: return
	is_dead = true
	
	remove_from_group("enemy")
	
	# Disable collisions and movement logic
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	if hp_bar:
		hp_bar.visible = false
		
	# Give XP to player
	if player and player.has_method("gain_xp"):
		var gold_lvl = Global.save_data.upgrades.get("gold_gain", 0)
		var gold_multiplier = 1.0 + gold_lvl  # +100% per level
		Global.add_gold(int(gold_reward * gold_multiplier))
		
		var xp_mult = 1.0
		var luck_chance = 0.05
		if "luck_multiplier" in player:
			luck_chance += (player.luck_multiplier - 1.0)
			
		var roll = randf()
		if roll < luck_chance * 0.1: # Rare 3x
			xp_mult = 3.0
		elif roll < luck_chance: # 2x
			xp_mult = 2.0
			
		if xp_mult > 1.0:
			Global.console_log("Lucky! %dx XP from enemy kill." % xp_mult)
			
		player.gain_xp(xp_reward * xp_mult)
	
	# Death Animation
	if sprite and sprite is AnimatedSprite2D and sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
		await sprite.animation_finished
	
	queue_free()

extends CharacterBody2D

@export var speed: float = 100.0
@export var health: float = 10.0
@export var damage: float = 10.0
@export var drops_chest: bool = false

var max_health: float = 10.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var hp_bar = get_node_or_null("HealthBar")

func _ready():
	# Wait a frame to ensure game.gd has applied multipliers
	await get_tree().process_frame
	max_health = health
	if hp_bar:
		hp_bar.max_value = max_health
		hp_bar.value = health

func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		
		# Simple collision damage (if using CharacterBody2D collision)
		# Usually better to use Area2D for hitboxes, but this is a start
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.has_method("take_damage") and collider.name == "Player": # Name check is a bit brittle, ideally use groups or class_name
				collider.take_damage(damage * delta) # Continuous damage

func take_damage(amount: float):
	health -= amount
	if hp_bar:
		hp_bar.value = health
	Global.log("Enemy took " + str(amount) + " damage. Remaining HP: " + str(health))
	if health <= 0:
		if drops_chest:
			call_deferred("_spawn_chest")
		die()

func _spawn_chest():
	var chest = preload("res://Scenes/chest.tscn").instantiate()
	chest.process_mode = Node.PROCESS_MODE_PAUSABLE
	chest.global_position = global_position
	get_parent().add_child(chest)

func die():
	# Give XP to player
	if player and player.has_method("gain_xp"):
		var xp_mult = 1.0
		var luck_chance = 0.05
		if "luck_multiplier" in player:
			luck_chance += (player.luck_multiplier - 1.0)
			
		if randf() < luck_chance:
			xp_mult = 2.0
		if randf() < luck_chance * 0.1: # Rare
			xp_mult = 3.0
			
		if xp_mult > 1.0:
			Global.log("Lucky! %dx XP from enemy kill." % xp_mult)
			
		player.gain_xp(10.0 * xp_mult)
	queue_free()

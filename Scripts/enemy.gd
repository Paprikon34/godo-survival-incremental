extends CharacterBody2D

@export var speed: float = 100.0
@export var health: float = 10.0
@export var damage: float = 10.0

@onready var player = get_tree().get_first_node_in_group("player")

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
	if health <= 0:
		die()

func die():
	# Give XP to player
	if player and player.has_method("gain_xp"):
		player.gain_xp(10.0)
	queue_free()

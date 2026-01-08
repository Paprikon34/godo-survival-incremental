extends CharacterBody2D

@export var speed: float = 200.0
@export var health: float = 100.0
@export var experience: float = 0.0
@export var level: int = 1

func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()

func take_damage(amount: float):
	health -= amount
	print("Player took damage: ", amount, " Current health: ", health)
	if health <= 0:
		die()

func gain_xp(amount: float):
	experience += amount
	print("Gained XP: ", amount)
	# Simple leveling logic for now
	if experience >= level * 100:
		level_up()

func level_up():
	experience -= level * 100
	level += 1
	print("Level Up! New Level: ", level)

func die():
	print("Player Died!")
	# Reload scene or show game over
	get_tree().reload_current_scene()

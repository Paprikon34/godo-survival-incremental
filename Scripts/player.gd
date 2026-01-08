extends CharacterBody2D

signal level_up

@export var speed: float = 200.0
@export var max_health: float = 100.0
@export var health: float = 100.0
@export var experience: float = 0.0
@export var level: int = 1
@export var damage_multiplier: float = 1.0
@export var xp_multiplier: float = 1.0
@export var luck_multiplier: float = 1.0
@export var regeneration: float = 0.5 # HP per second

var regen_timer: float = 0.0

@onready var hp_bar = get_node_or_null("HealthBar")

func _ready():
	if hp_bar:
		hp_bar.max_value = max_health
		hp_bar.value = health
		hp_bar.visible = false

func _physics_process(delta):
	# Regeneration logic
	regen_timer += delta
	if regen_timer >= 1.0:
		regen_timer = 0.0
		if health < max_health:
			health = min(health + regeneration, max_health)
			update_hp_bar()

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()

func update_hp_bar():
	if hp_bar:
		hp_bar.max_value = max_health
		hp_bar.value = health
		hp_bar.visible = health < max_health

func take_damage(amount: float):
	health -= amount
	update_hp_bar()
	# print("Player took damage: ", amount, " Current health: ", health) # Commented out spam
	if health <= 0:
		die()

func gain_xp(amount: float):
	experience += amount * xp_multiplier
	# print("Gained XP: ", amount)
	# Simple leveling logic for now
	while experience >= level * 100:
		_trigger_level_up()

func _trigger_level_up():
	experience -= level * 100
	level += 1
	emit_signal("level_up")
	Global.log("Level Up! New Level: " + str(level))

func die():
	Global.log("Player Died!")
	# Reload scene or show game over
	get_tree().reload_current_scene()

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
@export var piercing_count: int = 0
@export var regeneration: float = 0.5 # HP per second
@export var defense: float = 0.0

var regen_timer: float = 0.0

@onready var hp_bar = get_node_or_null("HealthBar")

func _ready():
	# Force collision bits
	collision_layer = 1 # Player layer
	collision_mask = 2  # Hit enemies
	
	# Apply Permanent Upgrades
	var upgrades = Global.save_data.upgrades
	var disabled = Global.save_data.get("disabled_upgrades", [])
	
	# Health: +10 per level (Max 5)
	if "health" not in disabled:
		var hp_bonus = upgrades.health * 10
		max_health += hp_bonus
	health = max_health # Restore full HP
	
	# Speed: +20 per level (Max 3)
	if "speed" not in disabled:
		var speed_bonus = upgrades.speed * 20
		speed += speed_bonus
	
	# Damage: +5% per level (Max 5)
	if "damage" not in disabled:
		var dmg_bonus = upgrades.damage * 0.05
		damage_multiplier += dmg_bonus
		
	# Regeneration: +0.5 per level (Max 3)
	if "regeneration" not in disabled:
		var regen_bonus = upgrades.get("regeneration", 0) * 0.5
		regeneration += regen_bonus
	
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

	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()

var is_god_mode: bool = false

func update_hp_bar():
	if hp_bar:
		hp_bar.max_value = max_health
		hp_bar.value = health
		hp_bar.visible = health < max_health

func take_damage(amount: float):
	if is_god_mode: return
	var damage_taken = max(0.0, amount - defense)
	health -= damage_taken
	update_hp_bar()
	
	Global.console_log("Player took damage: %.1f. HP: %d/%d" % [damage_taken, health, max_health])
	
	if health <= 0:
		die()

func gain_xp(amount: float):
	experience += amount * xp_multiplier
	# print("Gained XP: ", amount)
	# Simple leveling logic for now
	while experience >= level * 80:
		_trigger_level_up()

func _trigger_level_up():
	experience -= level * 80 # Match the requirement
	level += 1
	emit_signal("level_up")
	Global.console_log("Level Up! New Level: " + str(level))

func die():
	Global.console_log("Player Died!")
	# Reload scene or show game over
	get_tree().call_deferred("reload_current_scene")

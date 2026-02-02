extends CharacterBody2D

@export var stats: EnemyData
@export var speed: float = 120.0
@export var health: float = 1000.0
@export var damage: float = 20.0

var max_health: float = 1000.0
var is_dead = false
var is_active = false

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var hp_bar = $HealthBar

enum State { IDLE, CHASING, DASHING, SHOOTING, SPECIAL }
var current_state = State.IDLE

var state_timer = 0.0

func _ready():
	if stats:
		health = stats.health
		max_health = stats.health
	
	add_to_group("enemy")
	hp_bar.max_value = max_health
	hp_bar.value = health
	
	# Register with game UI if possible
	var game = get_tree().get_first_node_in_group("game")
	if game and game.has_method("add_active_boss"):
		game.add_active_boss(self)

func start_boss_fight():
	# Intro animation: land from above
	var start_pos = global_position + Vector2(0, -500)
	var target_pos = global_position
	global_position = start_pos
	
	sprite.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(self, "global_position", target_pos, 0.8).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	screenshake(0.5, 10.0)
	is_active = true
	set_state(State.CHASING)

func screenshake(duration: float, intensity: float):
	var cam = get_viewport().get_camera_2d()
	if cam:
		var original_offset = cam.offset
		var shake_tween = create_tween()
		for i in range(10):
			shake_tween.tween_property(cam, "offset", original_offset + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)), duration/10.0)
		shake_tween.tween_property(cam, "offset", original_offset, 0.1)

func set_state(new_state):
	current_state = new_state
	state_timer = 0.0
	
	match current_state:
		State.DASHING:
			state_timer = 1.0 # Dash duration
			# Dash towards player
			if player:
				var dir = (player.global_position - global_position).normalized()
				velocity = dir * speed * 4.0
		State.SHOOTING:
			state_timer = 2.0
		State.SPECIAL:
			state_timer = 3.0

func _physics_process(delta):
	if not is_active or is_dead: return
	
	state_timer += delta
	
	match current_state:
		State.CHASING:
			if player:
				var dir = (player.global_position - global_position).normalized()
				velocity = dir * speed
				move_and_slide()
				
				if state_timer > 3.0:
					set_state(State.DASHING if randf() < 0.5 else State.SHOOTING)
					
		State.DASHING:
			move_and_slide()
			# Visual effect
			sprite.modulate = Color(1, 1, 0) # Flash yellow
			if state_timer > 1.0:
				sprite.modulate = Color(1, 1, 1)
				set_state(State.CHASING)
				
		State.SHOOTING:
			velocity = Vector2.ZERO
			if int(state_timer * 10) % 5 == 0:
				shoot_circular()
			if state_timer > 1.5:
				set_state(State.CHASING)
				
	# 1. Physical Collision Damage
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.has_method("take_damage") and collider.is_in_group("player"):
			collider.take_damage(damage * delta * 5.0) # Continuous damage
			
	# 2. Distance-based damage (Safety net)
	if player and global_position.distance_to(player.global_position) < 80.0:
		if player.has_method("take_damage"):
			player.take_damage(damage * delta * 5.0)

func shoot_circular():
	var num_bullets = 8
	for i in range(num_bullets):
		var angle = (PI * 2 / num_bullets) * i
		var dir = Vector2(cos(angle), sin(angle))
		spawn_projectile(dir)

func spawn_projectile(direction: Vector2):
	var bullet_scene = load("res://Scenes/projectile.tscn")
	if bullet_scene:
		var b = bullet_scene.instantiate()
		b.global_position = global_position
		# Projectile needs to know it's from the boss
		if b.has_method("setup"):
			b.setup(direction, 350.0, damage)
		else:
			# Direct property assignment
			b.direction = direction
			b.speed = 350.0 # Slightly faster
			b.damage = damage
			b.target_group = "player" # Boss hits player
			
		get_parent().add_child(b)
		# Ensure projectile moves during pause
		b.process_mode = Node.PROCESS_MODE_ALWAYS

func take_damage(amount: float):
	if is_dead: return
	health -= amount
	hp_bar.value = health
	if health <= 0:
		die()

func die():
	is_dead = true
	# Cool death effect
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ZERO, 1.0)
	tween.parallel().tween_property(sprite, "rotation", PI * 4, 1.0)
	await tween.finished
	queue_free()

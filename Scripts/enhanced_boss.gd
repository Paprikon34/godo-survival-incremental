extends CharacterBody2D

@export var stats: EnemyData
@export var speed: float = 120.0
@export var health: float = 1000.0
@export var damage: float = 20.0

@export var max_health: float = 1000.0
var is_dead = false
var is_active = false

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $AnimatedSprite2D
@onready var hp_bar = $HealthBar

# Preload scenes locally to be safe
const PROJECTILE_SCENE_PATH = "res://Scenes/projectile.tscn"
const MINION_SCENE_PATH = "res://Scenes/enemy.tscn"

enum State { IDLE, CHASING, DASHING, SHOOTING, BARRAGE, SPIRAL, SUMMONING }
var current_state = State.IDLE

var state_timer = 0.0
var attack_cooldown_timer = 0.0
var shoot_timer = 0.0
var angle_accumulator = 0.0

# Attack Weights (Higher number = more frequent)
var ATTACK_WEIGHTS = {
	State.SHOOTING: 30,
	State.BARRAGE: 30,
	State.SPIRAL: 20,
	State.DASHING: 15,
	State.SUMMONING: 5
}

func _ready():
	if stats:
		health = stats.health
		max_health = stats.health
	else:
		# If no stats provided, ensure max_health matches the exported health value
		max_health = health
	
	add_to_group("enemy")
	if hp_bar:
		hp_bar.max_value = max_health
		hp_bar.value = health
	
	collision_layer = 2 # Enemy layer
	collision_mask = 1  # Hit player
	
	# Register with game UI
	var game = get_tree().get_first_node_in_group("game")
	if game and game.has_method("add_active_boss"):
		game.add_active_boss(self)

func start_boss_fight():
	# Intro animation
	var target_pos = global_position
	var start_pos = global_position + Vector2(0, -500)
	global_position = start_pos
	
	if sprite:
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
	shoot_timer = 0.0
	angle_accumulator = 0.0
	
	Global.console_log("BOSS STATE -> " + State.keys()[current_state])
	
	if sprite:
		match current_state:
			State.CHASING:
				sprite.modulate = Color(1, 1, 1)
				sprite.play("move")
				sprite.speed_scale = 1.0
				attack_cooldown_timer = 0.0 # Reset cooldown counting
				
			State.DASHING:
				sprite.modulate = Color(1, 0.5, 0) # Orange
				sprite.play("move")
				sprite.speed_scale = 2.0 # Faster animation during dash
				if is_instance_valid(player):
					var dir = (player.global_position - global_position).normalized()
					velocity = dir * speed * 4.0 # Dash fast
					
			State.SHOOTING: # Circular Blast
				sprite.modulate = Color(1, 0.2, 0.2) # Red
				sprite.speed_scale = 1.0
				sprite.play("stomp") # Custom stomp animation
				shoot_circular()
				
			State.BARRAGE: # Machine Gun
				sprite.modulate = Color(0.2, 0.2, 1) # Blue
				sprite.speed_scale = 1.0
				sprite.play("barrage") # Custom jittery animation
				
			State.SPIRAL: # Rotating pattern
				sprite.modulate = Color(0.8, 0.2, 0.8) # Purple
				sprite.speed_scale = 1.0
				sprite.play("spiral") # Custom wind-up animation
				
			State.SUMMONING:
				sprite.modulate = Color(0.2, 1, 0.2) # Green
				sprite.speed_scale = 1.0
				sprite.play("stomp") # Stomp to summon
				spawn_minions()

func _physics_process(delta):
	if is_dead: return
	
	# Initial Activation Failsafe
	if not is_active and is_inside_tree():
		state_timer += delta
		if state_timer > 2.0:
			Global.console_log("Boss Force Start (Failsafe)")
			is_active = true
			set_state(State.CHASING)
	
	if not is_active: return
	
	# Update timers
	state_timer += delta
	shoot_timer += delta
	
	# Ensure player exists
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		
	# --- STATE MACHINE ---
	match current_state:
		State.CHASING:
			# Movement Logic
			if is_instance_valid(player):
				var dir = (player.global_position - global_position).normalized()
				velocity = dir * speed
				
				if sprite:
					if velocity.x > 0:
						sprite.flip_h = true
					elif velocity.x < 0:
						sprite.flip_h = false
						
				move_and_slide()
			else:
				velocity = velocity.lerp(Vector2.ZERO, delta * 5.0)
				move_and_slide()
			
			# Attack Selector Logic
			attack_cooldown_timer += delta
			if attack_cooldown_timer >= 3.0: # Explicit 3 second interval
				choose_attack()

		State.DASHING:
			move_and_slide() # Continue moving in initial direction
			if state_timer > 0.8: # Short dash
				set_state(State.CHASING)
				
		State.SHOOTING:
			velocity = velocity.lerp(Vector2.ZERO, delta * 5.0)
			move_and_slide()
			# One-shot attack handled in set_state, verify end
			if state_timer > 1.0:
				set_state(State.CHASING)

		State.BARRAGE:
			velocity = velocity.lerp(Vector2.ZERO, delta * 5.0)
			move_and_slide()
			
			if shoot_timer > 0.1: # 10 shots/sec
				shoot_timer = 0.0
				if is_instance_valid(player):
					var dir = (player.global_position - global_position).normalized()
					dir = dir.rotated(randf_range(-0.15, 0.15)) # Slight spread
					spawn_projectile(dir)
					
			if state_timer > 2.0: # 2 seconds of shooting
				set_state(State.CHASING)
				
		State.SPIRAL:
			velocity = velocity.lerp(Vector2.ZERO, delta * 5.0)
			move_and_slide()
			
			angle_accumulator += delta * 6.0 # Rotation speed
			if shoot_timer > 0.05: # Very fast fire rate
				shoot_timer = 0.0
				var dir1 = Vector2(cos(angle_accumulator), sin(angle_accumulator))
				var dir2 = Vector2(cos(angle_accumulator + PI), sin(angle_accumulator + PI))
				spawn_projectile(dir1)
				spawn_projectile(dir2)
				
			if state_timer > 3.0:
				set_state(State.CHASING)
				
		State.SUMMONING:
			velocity = velocity.lerp(Vector2.ZERO, delta * 5.0)
			move_and_slide()
			if state_timer > 1.0:
				set_state(State.CHASING)

	# Collision Damage
	_handle_collision_damage(delta)

func choose_attack():
	Global.console_log("Boss choosing attack...")
	var total_weight = 0
	for w in ATTACK_WEIGHTS.values():
		total_weight += w
		
	var roll = randi_range(0, total_weight)
	var current_weight = 0
	
	for state in ATTACK_WEIGHTS.keys():
		current_weight += ATTACK_WEIGHTS[state]
		if roll <= current_weight:
			set_state(state)
			return

func _handle_collision_damage(delta):
	# Physical Collision
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.has_method("take_damage") and collider.is_in_group("player"):
			collider.take_damage(damage * delta * 5.0)
			
	# Distance Safety Net
	if is_instance_valid(player) and global_position.distance_to(player.global_position) < 80.0:
		if player.has_method("take_damage"):
			player.take_damage(damage * delta * 5.0)

# --- ACTIONS ---

func shoot_circular():
	Global.console_log("Boss performing Circular Blast")
	var num_bullets = 12
	for i in range(num_bullets):
		var angle = (PI * 2 / num_bullets) * i
		var dir = Vector2(cos(angle), sin(angle))
		spawn_projectile(dir)

func spawn_projectile(dir: Vector2):
	var p_scene = load(PROJECTILE_SCENE_PATH)
	if not p_scene: return
	
	var p = p_scene.instantiate()
	p.direction = dir
	p.speed = 450.0
	p.damage = damage
	p.target_group = "player"
	
	# Safe local positioning
	p.position = position 
	p.z_index = 4096 
	
	var parent = get_parent()
	if parent:
		parent.call_deferred("add_child", p)
		p.set_deferred("position", position)

func spawn_minions():
	Global.console_log("Boss summoning minions (Wide Spread)")
	var num_minions = 4
	var minion_s = load(MINION_SCENE_PATH)
	if not minion_s: return
	
	for i in range(num_minions):
		var angle = (PI * 2 / num_minions) * i
		# Spawn further away (220px) to prevent sticking
		var offset = Vector2(cos(angle), sin(angle)) * 220.0 
		var spawn_pos = position + offset # Use local position relative to arena
		
		var enemy = minion_s.instantiate()
		enemy.z_index = z_index + 1
		
		# Nerf minions slightly
		if "hp_mult" in enemy: enemy.hp_mult = 0.5
		if "speed_mult" in enemy: enemy.speed_mult = 0.8
		
		get_parent().call_deferred("add_child", enemy)
		# Use position, not global_position, for arena compatibility
		enemy.set_deferred("position", spawn_pos) 

func take_damage(amount: float):
	if is_dead: return
	health -= amount
	if hp_bar: hp_bar.value = health
	
	# Global.console_log("Boss HP: %.0f" % health)
	if health <= 0:
		die()

func die():
	is_dead = true
	if sprite:
		# Cool death effect
		sprite.play("death")
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 1.5)
		await sprite.animation_finished
	queue_free()

extends CharacterBody2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 0.0
var damage: float = 0.0
var lifetime: float = 5.0
var has_hit: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _physics_process(delta):
	if has_hit: return
	
	var velocity_vec = direction * speed * delta
	var collision = move_and_collide(velocity_vec)
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		return

	if collision:
		var collider = collision.get_collider()
		if is_instance_valid(collider) and collider.is_in_group("enemy"):
			has_hit = true
			if collider.has_method("take_damage"):
				collider.take_damage(damage)
			queue_free()

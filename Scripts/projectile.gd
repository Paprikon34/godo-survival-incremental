extends CharacterBody2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 0.0
var damage: float = 0.0
var lifetime: float = 5.0

func _physics_process(delta):
	velocity = direction * speed
	move_and_slide()
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.has_method("take_damage") and collider.is_in_group("enemy"):
			collider.take_damage(damage)
			queue_free()

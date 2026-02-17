extends Area2D

@export var speed: float = 600.0
@export var damage: float = 20.0
@export var lifetime: float = 1.2

var direction: Vector2 = Vector2.RIGHT
var pierce_count: int = 0

func _ready():
	# Rotate the dagger to face movement direction
	rotation = direction.angle()
	
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
			_after_hit()

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			_after_hit()

func _after_hit():
	if pierce_count > 0:
		pierce_count -= 1
	else:
		queue_free()

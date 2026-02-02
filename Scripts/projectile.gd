extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 0.0
var damage: float = 0.0
var lifetime: float = 5.0
var pierce_count: int = 0
var target_group: String = "enemy"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group(target_group):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			
		pierce_count -= 1
		if pierce_count < 0:
			queue_free()

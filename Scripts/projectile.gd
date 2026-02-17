extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 0.0
var damage: float = 0.0
var lifetime: float = 5.0
var pierce_count: int = 0
var target_group: String = "enemy"

func _ready():
	body_entered.connect(_on_body_entered)
	z_index = 100
	# Force high visibility
	var s = get_node_or_null("Sprite2D")
	if s:
		s.modulate = Color(3, 0, 3) # Glowing Magenta

func _physics_process(delta):
	# Move using local position (safer inside the arena)
	position += direction * speed * delta
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group(target_group):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		if pierce_count > 0:
			pierce_count -= 1
		else:
			queue_free()

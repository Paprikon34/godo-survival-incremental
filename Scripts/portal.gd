extends Area2D

var boss_type: String = ""
@onready var sprite = $AnimatedSprite2D

func _ready():
	connect("body_entered", _on_body_entered)
	add_to_group("portal")
	if sprite:
		sprite.play("default")

var time: float = 0.0

func _process(delta):
	time += delta
	if sprite:
		sprite.rotate(delta * 1.0) # Slower, more stable rotation
		# Subtle pulsing for idle feel
		var pulse = 1.0 + sin(time * 2.0) * 0.05
		sprite.scale = Vector2(pulse, pulse) * 1.5

func _on_body_entered(body):
	if body.is_in_group("player"):
		var game = get_tree().get_first_node_in_group("game")
		if game and game.has_method("enter_boss_arena"):
			game.enter_boss_arena(boss_type)
			queue_free()

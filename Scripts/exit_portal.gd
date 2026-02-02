extends Area2D

@onready var sprite = $AnimatedSprite2D

func _ready():
	connect("body_entered", _on_body_entered)
	if sprite:
		sprite.modulate = Color.CYAN # Distinguish from entry portal
		sprite.play("default")

var time: float = 0.0

func _process(delta):
	time += delta
	if sprite:
		sprite.rotate(-delta * 1.5) # Consistent stable rotation
		# Subtle pulsing
		var pulse = 1.0 + sin(time * 2.5) * 0.05
		sprite.scale = Vector2(pulse, pulse) * 1.2

func _on_body_entered(body):
	if body.is_in_group("player"):
		var game = get_tree().get_first_node_in_group("game")
		if game and game.has_method("exit_boss_arena"):
			game.exit_boss_arena()
			queue_free()

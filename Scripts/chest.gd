extends Area2D

@onready var sprite = $AnimatedSprite2D

var collected = false

func _ready():
	connect("body_entered", _on_body_entered)
	if sprite:
		sprite.process_mode = Node.PROCESS_MODE_ALWAYS
		sprite.play("idle")

func _on_body_entered(body):
	if collected: return
	
	if body.is_in_group("player"):
		collected = true
		var game = get_tree().get_first_node_in_group("game")
		if game and game.has_method("on_chest_collected"):
			game.on_chest_collected()
		
		if sprite:
			Global.console_log("DEBUG: Chest Open Animation Starting")
			sprite.play("open")
			await sprite.animation_finished
			Global.console_log("DEBUG: Chest Open Animation Finished")
		
		queue_free()

extends Area2D

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		var game = body.get_parent() # Assuming Player is child of Game
		if game.has_method("on_chest_collected"):
			game.on_chest_collected()
		queue_free()

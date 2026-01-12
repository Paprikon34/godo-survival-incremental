extends Area2D

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer

var collected = false

func _ready():
	connect("body_entered", _on_body_entered)
	if anim_player:
		anim_player.play("idle")

func _on_body_entered(body):
	if collected: return
	
	if body.is_in_group("player"):
		collected = true
		var game = body.get_parent()
		if game.has_method("on_chest_collected"):
			game.on_chest_collected()
		
		if anim_player:
			anim_player.play("open")
			await anim_player.animation_finished
		
		queue_free()

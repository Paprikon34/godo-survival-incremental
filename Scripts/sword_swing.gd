extends Area2D

@export var damage: float = 15.0
@export var swing_arc: float = 200.0 # Degrees
@export var swing_duration: float = 0.25

func _ready():
	# Initial appearance
	modulate.a = 0
	scale = Vector2(0.5, 0.5)
	
	# Connect collision signals
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Execute the swing animation
	_perform_swing()

func _perform_swing():
	var tween = create_tween()
	
	# Show and expand
	tween.tween_property(self, "modulate:a", 1.0, 0.05)
	tween.parallel().tween_property(self, "scale", Vector2(3.0, 3.0), swing_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Rotate for the "arc" effect - Ensure it always slashes Top to Bottom
	var half_arc = deg_to_rad(swing_arc / 2.0)
	var start_rot = rotation - half_arc
	var end_rot = rotation + half_arc
	
	# Detect if we are facing Left (the midpoint rotation for Left is 270/PI*1.5)
	# If cos(rotation - PI/2) is negative, we are facing left.
	if cos(rotation - PI/2.0) < -0.1:
		# For the left side, we need to reverse to stay Top-to-Bottom
		start_rot = rotation + half_arc
		end_rot = rotation - half_arc
	
	rotation = start_rot
	tween.parallel().tween_property(self, "rotation", end_rot, swing_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Fade out at the end
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	
	await tween.finished
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		if area.has_method("take_damage"):
			area.take_damage(damage)

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

extends Area2D

@export var damage: float = 20.0
@export var rotation_speed: float = 4.0 # Speed of scythe spinning on its own axis

func _ready():
	# Scythes usually stay alive as long as the weapon exists
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	# Spin the scythe as it orbits
	$Sprite2D.rotation += rotation_speed * delta

func get_actual_damage() -> float:
	var final_dmg = damage
	var weapon = get_parent()
	if weapon:
		var player = weapon.get_parent()
		if player and "damage_multiplier" in player:
			final_dmg *= player.damage_multiplier
	return final_dmg

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		if area.has_method("take_damage"):
			area.take_damage(get_actual_damage())

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(get_actual_damage())

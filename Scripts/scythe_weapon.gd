extends Node2D

@export var orbit_speed: float = 3.0
@export var radius: float = 250.0
@export var projectile_count: int = 1
@export var damage: float = 20.0

const SCYTHE_SCENE = preload("res://Scenes/scythe_projectile.tscn")

func _ready():
	update_scythes()

func _process(delta):
	# Rotate the entire weapon container
	var mult = 1.0
	var player = get_parent()
	if player and "attack_speed_multiplier" in player:
		mult = player.attack_speed_multiplier
	rotation += (orbit_speed * mult) * delta

func update_scythes():
	# Clean up existing scythes
	for child in get_children():
		child.queue_free()
	
	# Create new scythes at calculated angles
	for i in range(projectile_count):
		var scythe = SCYTHE_SCENE.instantiate()
		add_child(scythe)
		
		# Position scythe at radius
		var angle = (PI * 2 / projectile_count) * i
		scythe.position = Vector2(cos(angle), sin(angle)) * radius
		
		scythe.damage = damage

func upgrade():
	projectile_count += 1
	update_scythes()

extends Node2D

@export var grass_texture: Texture2D = preload("res://Sprites/grass14.png")

var background_sprite: Sprite2D
@onready var camera = get_viewport().get_camera_2d()

func _ready():
	# Use a Sprite2D with region enabled for hardware-accelerated tiling
	background_sprite = Sprite2D.new()
	background_sprite.texture = grass_texture
	background_sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	background_sprite.region_enabled = true
	background_sprite.centered = true
	background_sprite.z_index = -10
	add_child(background_sprite)

func _process(_delta):
	if not camera:
		camera = get_viewport().get_camera_2d()
		return

	var cam_pos = camera.global_position
	var viewport_size = get_viewport_rect().size
	var zoom = camera.zoom
	var visible_size = viewport_size / zoom
	
	# Snapping to integers prevents sub-pixel bleeding/gaps on some GPUs
	var top_left = (cam_pos - (visible_size / 2.0)).floor()
	var rounded_size = (visible_size + Vector2(2, 2)).ceil()
	background_sprite.region_rect = Rect2(top_left, rounded_size)
	background_sprite.global_position = top_left + (rounded_size / 2.0)

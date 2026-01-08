extends Node2D

@export var grid_size: int = 64
@export var grid_color: Color = Color(0.2, 0.2, 0.2, 1.0)

@onready var camera = get_viewport().get_camera_2d()

func _process(delta):
	queue_redraw()

func _draw():
	if not camera:
		camera = get_viewport().get_camera_2d()
		return

	var cam_pos = camera.global_position
	var viewport_size = get_viewport_rect().size
	var zoom = camera.zoom
	
	# Determine the visible area
	var top_left = cam_pos - (viewport_size / 2.0) / zoom
	var bottom_right = cam_pos + (viewport_size / 2.0) / zoom
	
	# Snap lines to grid
	var start_x = floor(top_left.x / grid_size) * grid_size
	var end_x = ceil(bottom_right.x / grid_size) * grid_size
	var start_y = floor(top_left.y / grid_size) * grid_size
	var end_y = ceil(bottom_right.y / grid_size) * grid_size
	
	for x in range(start_x, end_x + grid_size, grid_size):
		draw_line(Vector2(x, top_left.y), Vector2(x, bottom_right.y), grid_color, 1.0)
		
	for y in range(start_y, end_y + grid_size, grid_size):
		draw_line(Vector2(top_left.x, y), Vector2(bottom_right.x, y), grid_color, 1.0)

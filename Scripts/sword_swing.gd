extends Area2D

@export var damage: float = 15.0
@export var swing_arc: float = 200.0   # Degrees total arc width
@export var swing_duration: float = 0.20

# Track already-hit targets so we only deal damage once per swing
var _hit_targets: Array = []

# Draw state — driven by tweens
var _sweep_progress: float = 0.0   # 0 → 1 across swing_arc
var _alpha: float = 1.0

# Visual constants
const INNER_RADIUS: float = 16.0
const OUTER_RADIUS: float = 85.0
const SEGMENTS: int = 48

# Colors
const FILL_COLOR   := Color(1.00, 0.90, 0.45, 0.60)   # warm gold fill
const GLOW_COLOR   := Color(1.00, 1.00, 0.85, 1.00)   # bright leading edge
const TRAIL_COLOR  := Color(1.00, 0.80, 0.30, 0.20)   # soft trailing edge

func _ready():
	# Hide the old sprite if it exists in the scene
	for child in get_children():
		if child is Sprite2D:
			child.visible = false

	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

	_perform_swing()

func _perform_swing():
	_alpha = 1.0
	_sweep_progress = 0.0
	set_process(true)

	var tween = create_tween()
	tween.set_parallel(false)

	# 1. Sweep the arc quickly (QUAD ease out — fast start, decelerate at end)
	tween.tween_property(self, "_sweep_progress", 1.0, swing_duration) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 2. Hold for a brief moment so the full arc is visible
	tween.tween_interval(0.04)

	# 3. Fade out
	tween.tween_property(self, "_alpha", 0.0, 0.12) \
		.set_trans(Tween.TRANS_QUAD)

	tween.tween_callback(_on_done)

func _on_done():
	set_process(false)
	queue_free()

func _process(_delta: float):
	queue_redraw()

func _draw():
	if _sweep_progress <= 0.0 or _alpha <= 0.0:
		return

	# In local space the "forward" direction is -Y (angle = -PI/2).
	# The arc is centred on that axis and sweeps symmetrically ± half_arc.
	var half_rad  := deg_to_rad(swing_arc / 2.0)
	var center_a  := -PI / 2.0
	var start_a   := center_a - half_rad
	var end_a     := start_a + deg_to_rad(swing_arc) * _sweep_progress

	# --- Build ring-sector polygon ---
	var outer_pts: PackedVector2Array = []
	var inner_pts: PackedVector2Array = []

	for i in range(SEGMENTS + 1):
		var t     := float(i) / float(SEGMENTS)
		var angle := lerp(start_a, end_a, t)
		outer_pts.append(Vector2(cos(angle), sin(angle)) * OUTER_RADIUS)
		inner_pts.append(Vector2(cos(angle), sin(angle)) * INNER_RADIUS)

	# Combine: outer forward, inner reversed → closed polygon
	var poly: PackedVector2Array = outer_pts
	for i in range(inner_pts.size() - 1, -1, -1):
		poly.append(inner_pts[i])

	var fill := FILL_COLOR
	fill.a   *= _alpha
	draw_colored_polygon(poly, fill)

	# --- Outer arc outline — gradient brightness toward leading edge ---
	for i in range(SEGMENTS):
		var t0    := float(i)     / float(SEGMENTS)
		var t1    := float(i + 1) / float(SEGMENTS)
		var a0    := lerp(start_a, end_a, t0)
		var a1    := lerp(start_a, end_a, t1)
		var brt   := lerp(0.15, 1.0, t1)            # brighter closer to tip
		var c     := Color(1.0, 0.95, 0.6, brt * _alpha)
		draw_line(
			Vector2(cos(a0), sin(a0)) * OUTER_RADIUS,
			Vector2(cos(a1), sin(a1)) * OUTER_RADIUS,
			c, 2.0
		)

	# --- Leading edge glow (bright line at current tip) ---
	var tip_dir := Vector2(cos(end_a), sin(end_a))
	var glow    := GLOW_COLOR
	glow.a      *= _alpha
	draw_line(tip_dir * (INNER_RADIUS - 4.0), tip_dir * (OUTER_RADIUS + 8.0), glow, 3.5)

	# --- Trailing edge (soft, faint) ---
	var tail_dir := Vector2(cos(start_a), sin(start_a))
	var trail    := TRAIL_COLOR
	trail.a      *= _alpha
	draw_line(tail_dir * INNER_RADIUS, tail_dir * OUTER_RADIUS, trail, 1.5)

# ---- Collision / damage ---------------------------------------------------

func _on_area_entered(area: Area2D):
	if area.is_in_group("enemy") and area not in _hit_targets:
		_hit_targets.append(area)
		if area.has_method("take_damage"):
			area.take_damage(damage)

func _on_body_entered(body: Node2D):
	if body.is_in_group("enemy") and body not in _hit_targets:
		_hit_targets.append(body)
		if body.has_method("take_damage"):
			body.take_damage(damage)

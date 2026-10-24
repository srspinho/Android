extends "res://scripts/enemy_base.gd"
## Androide de segurança corporativa. Patrulha e atira quando vê o jogador.

var dir := -1
var _cd := 1.0


func _setup() -> void:
	hp = 3
	points = 200
	body_color = Color("#ffd000")
	contact_offset = Vector2(0, -12)
	contact_radius = 9.0
	add_box(Vector2(12, 24), Vector2(0, -12))


func _ai(delta: float, p) -> void:
	velocity.y = minf(velocity.y + GRAVITY * delta, 400.0)
	var dx: float = p.global_position.x - global_position.x
	var dy: float = p.global_position.y - global_position.y
	_cd -= delta
	if not p.dead and absf(dx) < 190.0 and absf(dy) < 24.0:
		dir = 1 if dx > 0.0 else -1
		velocity.x = 0.0
		if _cd <= 0.0:
			_cd = 1.4
			shoot(Vector2(dir, 0), Vector2(dir * 11, -15))
	else:
		if blocked_ahead(dir):
			dir = -dir
		velocity.x = dir * 35.0
	move_and_slide()


func _r(x: float, y: float, w: float, h: float, c: Color) -> void:
	if dir < 0:
		x = -x - w
	draw_rect(Rect2(x, y, w, h), tint(c))


func _draw() -> void:
	var step := sin(_t * 10.0) * 1.5 if absf(velocity.x) > 1.0 else 0.0
	_r(-5 + step, -8, 4, 8, Color("#3a3f55"))
	_r(1 - step, -8, 4, 8, Color("#3a3f55"))
	_r(-6, -20, 12, 12, Color("#262a3d"))
	_r(-6, -14, 12, 2, Color("#ffd000"))
	_r(-4, -27, 9, 7, Color("#3a3f55"))
	_r(0, -25, 5, 2, Color("#ffd000"))
	_r(-1, -31, 1, 4, Color("#8890a0"))
	_r(-2, -32, 3, 1, Color("#ff3355"))
	# Arma
	_r(3, -17, 9, 3, Color("#11131c"))
	_r(11, -16, 2, 1, Color("#ff7a1a"))

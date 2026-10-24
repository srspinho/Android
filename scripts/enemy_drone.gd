extends "res://scripts/enemy_base.gd"
## Drone de vigilância. Voa perto de onde nasceu e dispara mirando no jogador.

var _home := Vector2.ZERO
var _cd := 2.0


func _setup() -> void:
	hp = 2
	points = 150
	body_color = Color("#ff2bd6")
	contact_offset = Vector2.ZERO
	contact_radius = 8.0
	collision_mask = 1
	add_box(Vector2(14, 10), Vector2.ZERO)
	_home = position


func _ai(delta: float, p) -> void:
	var target := Vector2(_home.x, _home.y + sin(_t * 2.0) * 10.0)
	var dx: float = p.global_position.x - global_position.x
	if absf(dx) < 220.0:
		target.x = clampf(p.global_position.x, _home.x - 120.0, _home.x + 120.0)
	velocity = ((target - global_position) * 1.5).limit_length(70.0)
	move_and_slide()
	_cd -= delta
	if _cd <= 0.0 and not p.dead and absf(dx) < 200.0 and p.global_position.y > global_position.y:
		_cd = 2.2
		shoot(p.global_position + Vector2(0, -12) - global_position, Vector2(0, 6))


func _draw() -> void:
	var spin := sin(_t * 40.0) * 7.0
	draw_line(Vector2(-7 - spin, -7), Vector2(-7 + spin, -7), tint(Color("#8890a0")), 1.0)
	draw_line(Vector2(7 - spin, -7), Vector2(7 + spin, -7), tint(Color("#8890a0")), 1.0)
	draw_line(Vector2(-7, -6), Vector2(-5, -3), tint(Color("#3a3f55")), 1.0)
	draw_line(Vector2(7, -6), Vector2(5, -3), tint(Color("#3a3f55")), 1.0)
	draw_rect(Rect2(-7, -4, 14, 8), tint(Color("#1e1a33")))
	draw_rect(Rect2(-7, 3, 14, 1), tint(body_color))
	draw_circle(Vector2(0, 0), 5.0, Color(body_color, 0.2))
	draw_circle(Vector2(0, 0), 2.5, tint(Color("#ff3355")))
	draw_circle(Vector2(0, 0), 1.0, Color.WHITE)

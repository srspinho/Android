extends "res://scripts/enemy_base.gd"
## Androide de segurança corporativa. Patrulha e atira quando vê o jogador.

var dir := -1
var _cd := 1.0


func _setup() -> void:
	hp = 3
	points = 200
	body_color = Color("#ffd000")
	contact_offset = Vector2(0, -13)
	contact_radius = 10.0
	add_box(Vector2(14, 26), Vector2(0, -13))
	add_sprite(preload("res://art/guard.png"), 2, Vector2(0, -16))


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
			shoot(Vector2(dir, 0), Vector2(dir * 12, -16))
	else:
		if blocked_ahead(dir):
			dir = -dir
		velocity.x = dir * 35.0
	move_and_slide()
	sprite.flip_h = dir < 0
	sprite.frame = int(_t * 6.0) % 2 if velocity.x != 0.0 else 0

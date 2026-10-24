extends "res://scripts/enemy_base.gd"
## Cobra cibernética que fugiu dos laboratórios perto do Instituto Butantan.
## Rasteja devagar e dá o bote quando o jogador chega perto.

var dir := -1


func _setup() -> void:
	hp = 2
	points = 150
	body_color = Color("#39ff14")
	contact_offset = Vector2(0, -4)
	contact_radius = 8.0
	add_box(Vector2(18, 7), Vector2(0, -3.5))


func _ai(delta: float, p) -> void:
	velocity.y = minf(velocity.y + GRAVITY * delta, 400.0)
	var dx: float = p.global_position.x - global_position.x
	var dy: float = p.global_position.y - global_position.y
	var speed := 30.0
	if not p.dead and absf(dx) < 150.0 and absf(dy) < 20.0:
		dir = 1 if dx > 0.0 else -1
		speed = 85.0
	elif blocked_ahead(dir):
		dir = -dir
	velocity.x = dir * speed
	move_and_slide()


func _draw() -> void:
	for i in range(6, -1, -1):
		var x := -dir * (i * 3.0 - 6.0)
		var y := -4.0 + sin(_t * 12.0 + i) * 1.5
		var c := body_color if i % 2 == 0 else Color("#0f5a1f")
		draw_rect(Rect2(x - 2, y - 2, 4, 4), tint(c))
	var head := Vector2(dir * 9.0, -5.0)
	draw_rect(Rect2(head.x - 3, head.y - 2.5, 6, 5), tint(Color("#1d7a2c")))
	draw_rect(Rect2(head.x + dir * 1.0 - 0.5, head.y - 1.5, 1, 1), Color("#ff3355"))
	draw_line(head + Vector2(dir * 3, 1), head + Vector2(dir * 6, 1 + sin(_t * 20.0)), Color("#ff2bd6"), 1.0)

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
	add_box(Vector2(20, 8), Vector2(0, -4))
	add_sprite(preload("res://art/snake.png"), 2, Vector2(0, -8))


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
	sprite.flip_h = dir < 0
	sprite.frame = int(_t * (10.0 if speed > 50.0 else 4.0)) % 2

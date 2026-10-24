extends "res://scripts/enemy_base.gd"
## JARARACA-X, chefe da fase 2: cobra gigante criada nos laboratórios da
## Serpentis. Rasteja de um lado para o outro, se ergue e cospe veneno em
## leque. Fica mais rápida conforme perde vida. Enquanto ela viver, a saída
## da fase fica travada.

const MAX_HP := 30

var dir := -1

var _state := "crawl"
var _state_t := 0.0
var _spat := false


func _setup() -> void:
	hp = MAX_HP
	points = 5000
	body_color = Color("#54fc54")
	contact_offset = Vector2(0, -12)
	contact_radius = 20.0
	active_range = 260.0
	add_box(Vector2(56, 22), Vector2(0, -11))
	add_sprite(preload("res://art/boss.png"), 3, Vector2(0, -24))
	main.boss = self


func _ai(delta: float, p) -> void:
	_wake_up()
	velocity.y = minf(velocity.y + GRAVITY * delta, 400.0)
	_state_t += delta
	var rage := 1.0 + float(MAX_HP - hp) / MAX_HP  # 1 a 2
	if _state == "crawl":
		velocity.x = dir * 40.0 * rage
		if is_on_wall():
			dir = -dir
		sprite.frame = int(_t * 6.0 * rage) % 2
		if _state_t > 2.4 / rage:
			_state = "rear"
			_state_t = 0.0
			_spat = false
			dir = 1 if p.global_position.x > global_position.x else -1
	else:
		velocity.x = 0.0
		sprite.frame = 2
		if _state_t > 0.45 and not _spat:
			_spat = true
			_spit(p, 3 if rage < 1.5 else 5)
		if _state_t > 1.1:
			_state = "crawl"
			_state_t = 0.0
	sprite.flip_h = dir < 0
	move_and_slide()


## Cospe um leque de veneno a partir da boca, mirando no jogador.
func _spit(p, count: int) -> void:
	var mouth := Vector2(dir * 36, -32)
	var aim: Vector2 = (p.global_position + Vector2(0, -14)) - (global_position + mouth)
	for i in count:
		var spread := (i - (count - 1) / 2.0) * 0.22
		var b = shoot(aim.rotated(spread), mouth)
		b.color = Color("#54fc54")
		b.speed = 150.0


## Depois de acordar (jogador perto ou primeiro tiro), não dorme mais:
## nada de derrotar a chefe de longe enquanto ela está parada.
func _wake_up() -> void:
	active_range = 4000.0


func hurt(amount: int) -> void:
	_wake_up()
	super.hurt(amount)
	if hp <= 0:
		for i in 6:
			main.spawn_fx(global_position + Vector2(randf_range(-30, 30), randf_range(-30, 0)), Color("#54fc54"), 24.0)
		main.hud.show_message("JARARACA-X DESTRUÍDA! A saída está liberada")

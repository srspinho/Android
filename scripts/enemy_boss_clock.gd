extends "res://scripts/boss_base.gd"
## CRONOS-X, chefe da fase 3: o relógio da Torre da Praça do Relógio virou um
## drone gigante da Serpentis. Voa de um lado para o outro sobre a praça e
## dispara rajadas para baixo, mirando no jogador; só o tiro para cima alcança.
## Para no ar enquanto dispara: é a hora de acertar. Com menos da metade da
## vida, atira mais e solta drones menores.

const DroneScript := preload("res://scripts/enemy_drone.gd")
const GUNS := [Vector2(-20, 20), Vector2(20, 20)]

var _home := Vector2.ZERO
var _cd := 2.0
var _drone_cd := 4.0
var _attack_t := 0.0
var _fly_t := 0.0  # só avança enquanto ele voa (parado durante a rajada)
var _gun := 0
var _minions: Array = []


func _setup() -> void:
	max_hp = 50
	display_name = "CRONOS-X"
	defeat_message = "CRONOS-X DESTRUÍDO! A saída está liberada"
	points = 8000
	body_color = Color("#fcfc54")
	contact_offset = Vector2(0, 2)
	contact_radius = 20.0
	active_range = 230.0
	collision_mask = 0  # voa por cima de tudo
	add_box(Vector2(48, 44), Vector2(0, 2))
	add_sprite(preload("res://art/boss_clock.png"), 3, Vector2.ZERO)
	_home = position


func _ai(delta: float, p) -> void:
	wake_up()
	var rage := 1.0 + float(max_hp - hp) / max_hp  # 1 a 2
	_cd -= delta
	_attack_t -= delta
	if _attack_t <= 0.0:
		_fly_t += delta * rage
	var target := Vector2(_home.x + sin(_fly_t * 0.4) * 120.0, _home.y + sin(_t * 1.3) * 10.0)
	velocity = (target - global_position) * 2.0
	move_and_slide()

	if _cd <= 0.0:
		_cd = 2.6 / rage
		_attack_t = 0.9
		_burst(p, 5 if rage > 1.5 else 3)
	sprite.frame = 2 if _attack_t > 0.0 else int(_t * 4.0) % 2

	if rage > 1.5:
		_drone_cd -= delta
		_minions = _minions.filter(func(m): return is_instance_valid(m))
		if _drone_cd <= 0.0 and _minions.size() < 2:
			_drone_cd = 7.0
			var d = DroneScript.new()
			d.main = main
			d.position = global_position + Vector2(0, 34)
			main.world.add_child(d)
			_minions.append(d)


## Rajada em leque saindo de um dos canhões, mirando no jogador.
func _burst(p, count: int) -> void:
	Audio.sfx("boss_spit")
	var gun: Vector2 = GUNS[_gun]
	_gun = (_gun + 1) % GUNS.size()
	var aim: Vector2 = (p.global_position + Vector2(0, -14)) - (global_position + gun)
	for i in count:
		var b = shoot(aim.rotated((i - (count - 1) / 2.0) * 0.18), gun)
		b.color = Color("#fcfc54")
		b.speed = 160.0

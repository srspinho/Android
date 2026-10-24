extends CharacterBody2D
## Base dos inimigos: vida, dano por contato, tiro e ativação por distância.
## Cada inimigo sobrescreve _setup() (vida, sprite, colisão) e _ai().

const BulletScript := preload("res://scripts/bullet.gd")
const GRAVITY := 980.0
## Inimigos longe do jogador ficam parados para poupar bateria.
const ACTIVE_RANGE := 420.0

var main
var hp := 2
var points := 100
var body_color := Color("#ff3355")
var contact_offset := Vector2(0, -8)
var contact_radius := 9.0

var sprite: Sprite2D

var _flash := 0.0
var _t := 0.0


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1 | 16
	add_to_group("enemies")
	_setup()


func _setup() -> void:
	pass


func _ai(_delta: float, _player) -> void:
	pass


func _physics_process(delta: float) -> void:
	_t += delta
	_flash -= delta
	var p = main.player
	if p == null or global_position.distance_to(p.global_position) > ACTIVE_RANGE:
		return
	_ai(delta, p)
	sprite.modulate = Color(1, 0.35, 0.35) if _flash > 0.0 else Color.WHITE
	var hit_dist: float = (p.global_position + Vector2(0, -11)).distance_to(global_position + contact_offset)
	if not p.dead and hit_dist < contact_radius + 7.0:
		p.hurt(1)


## Cria o sprite a partir de uma tira de quadros.
func add_sprite(tex: Texture2D, frames: int, pos: Vector2) -> void:
	sprite = Sprite2D.new()
	sprite.texture = tex
	sprite.hframes = frames
	sprite.position = pos
	add_child(sprite)


func add_box(size: Vector2, offset: Vector2) -> void:
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	cs.shape = shape
	cs.position = offset
	add_child(cs)


func hurt(amount: int) -> void:
	hp -= amount
	_flash = 0.08
	if hp <= 0:
		main.add_score(points)
		main.spawn_fx(global_position + contact_offset, body_color, 16.0)
		queue_free()


func shoot(dir: Vector2, from: Vector2) -> void:
	var b = BulletScript.new()
	b.main = main
	b.from_player = false
	b.direction = dir.normalized()
	b.position = global_position + from
	main.world.add_child(b)


## Verdadeiro quando há parede ou buraco logo à frente.
func blocked_ahead(dir: int) -> bool:
	return is_on_wall() or (is_on_floor() and not main.is_solid_at(global_position + Vector2(dir * 10, 4)))

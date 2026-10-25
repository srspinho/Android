extends Area2D
## Barraquinha de dogão: encostou, a energia enche toda. Depois de servir,
## a barraquinha fecha por um tempo. A origem fica no chão, no meio do carrinho.

const STAND := preload("res://art/hotdog.png")
const COOLDOWN := 30.0

var main

var _closed := 0.0
var _sprite: Sprite2D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(36, 24)
	cs.shape = shape
	cs.position = Vector2(0, -12)
	add_child(cs)
	_sprite = Sprite2D.new()
	_sprite.texture = STAND
	_sprite.hframes = 2
	_sprite.position = Vector2(0, -20)
	add_child(_sprite)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if _closed > 0.0:
		_closed -= delta
	_sprite.frame = 1 if _closed > 0.0 else 0
	# Verifica a cada quadro: o jogador pode levar dano parado na barraquinha.
	var p = main.player
	if _closed <= 0.0 and not p.dead and p.hp < p.max_hp and overlaps_body(p):
		p.heal(p.max_hp)
		_closed = COOLDOWN
		main.hud.show_message("Dogão completo! Energia no máximo")
		Audio.sfx("hotdog")
		main.spawn_fx(global_position + Vector2(0, -24), Color("#fcfc54"), 14.0)


func _on_body_entered(body: Node) -> void:
	if body != main.player:
		return
	if _closed > COOLDOWN - 0.5:
		return  # acabou de servir neste toque
	if _closed > 0.0:
		main.hud.show_message("Barraquinha fechada. Volta em %d s" % ceili(_closed))
	elif body.hp >= body.max_hp:
		main.hud.show_message("Energia cheia: guarde o dogão pra depois!")

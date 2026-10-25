extends AnimatableBody2D
## Plataforma móvel ("mmm" no mapa): vai e volta na horizontal entre as marcas
## ":" (ou até bater numa parede). Como as plataformas finas, dá para pular
## nela por baixo e descer com baixo + pulo. A origem é o canto de cima à esquerda.

const TEX := preload("res://art/platform.png")
const SPEED := 40.0
## Caracteres do mapa que fazem a plataforma voltar.
const STOPS := ":#="

var main
var width_cells := 3
var dir := 1

var _t := 0.0
var _sprite: Sprite2D


func _ready() -> void:
	collision_layer = 16
	collision_mask = 0
	var w := width_cells * 16.0
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(w, 6)
	cs.shape = shape
	cs.position = Vector2(w / 2.0, 3)
	cs.one_way_collision = true
	add_child(cs)
	_sprite = Sprite2D.new()
	_sprite.texture = TEX
	_sprite.hframes = 2
	_sprite.centered = false
	_sprite.scale.x = width_cells / 3.0
	add_child(_sprite)


func _physics_process(delta: float) -> void:
	_t += delta
	var step := dir * SPEED * delta
	var row := floori(position.y / 16.0)
	# Célula em que a frente da plataforma vai entrar
	var front := position.x + step + (width_cells * 16.0 - 0.01 if dir > 0 else 0.0)
	if STOPS.contains(main.char_at(floori(front / 16.0), row)):
		dir = -dir
	else:
		position.x += step
	_sprite.frame = int(_t * 10.0) % 2

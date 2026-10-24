extends Area2D
## Itens coletáveis e a saída da fase.
##  +  coxinha energética (recupera energia)
##  K  cartão de acesso vermelho
##  W  turbo no blaster (tiro rápido)
##  *  chip de dados (pontos)
##  E  saída da fase

const ITEMS := preload("res://art/items.png")
const EXIT := preload("res://art/exit.png")
## Quadro de cada item em art/items.png
const FRAMES := {"+": 0, "K": 1, "W": 2, "*": 3}

var main
var kind := "*"

var _t := 0.0
var _sprite: Sprite2D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	if kind == "E":
		shape.size = Vector2(14, 30)
		cs.position = Vector2(0, -7)
	else:
		shape.size = Vector2(12, 12)
	cs.shape = shape
	add_child(cs)
	body_entered.connect(_on_body_entered)
	_t = position.x * 0.05

	_sprite = Sprite2D.new()
	if kind == "E":
		_sprite.texture = EXIT
		_sprite.position = Vector2(0, -16)
	else:
		_sprite.texture = ITEMS
		_sprite.hframes = 4
		_sprite.frame = FRAMES[kind]
	add_child(_sprite)


func _process(delta: float) -> void:
	_t += delta
	if kind != "E":
		_sprite.position.y = roundf(sin(_t * 3.0) * 2.0)  # flutua


func _on_body_entered(body: Node) -> void:
	if body != main.player:
		return
	match kind:
		"+":
			body.heal(2)
			main.hud.show_message("Coxinha energética! +2 de energia")
		"K":
			body.has_keycard = true
			main.hud.show_message("Cartão de acesso VERMELHO obtido!")
		"W":
			body.rapid_fire = 15.0
			main.hud.show_message("Turbo no blaster: tiro rápido por 15 s")
		"*":
			main.add_score(250)
		"E":
			main.level_complete()
			return
	main.spawn_fx(global_position, _glow(), 10.0)
	queue_free()


func _glow() -> Color:
	match kind:
		"+":
			return Color("#ffb347")
		"K":
			return Color("#ff3355")
		"W":
			return Color("#00f0ff")
		"E":
			return Color("#39ff14")
	return Color("#c6ff00")


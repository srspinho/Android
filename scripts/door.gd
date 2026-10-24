extends StaticBody2D
## Barreira de laser que só abre com o cartão de acesso da mesma cor.
## A origem fica no topo da porta.

var main
var height_cells := 1
var card := "red"

var _t := 0.0
var _height := 16.0


func _ready() -> void:
	collision_layer = 1
	_height = height_cells * 16.0
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(8, _height)
	cs.shape = shape
	cs.position = Vector2(0, _height / 2.0)
	add_child(cs)

	var sensor := Area2D.new()
	sensor.collision_layer = 0
	sensor.collision_mask = 2
	var scs := CollisionShape2D.new()
	var sshape := RectangleShape2D.new()
	sshape.size = Vector2(22, _height)
	scs.shape = sshape
	scs.position = cs.position
	sensor.add_child(scs)
	add_child(sensor)
	sensor.body_entered.connect(_on_touch)


func _on_touch(body: Node) -> void:
	if body != main.player:
		return
	if body.keycards.get(card, false):
		main.hud.show_message("Acesso liberado!")
		main.spawn_fx(global_position + Vector2(0, _height / 2.0), _laser(1.0), 20.0)
		queue_free()
	else:
		main.hud.show_message("Acesso negado: precisa do CARTÃO %s" % ("AZUL" if card == "blue" else "VERMELHO"))


func _laser(alpha: float) -> Color:
	return Color(0.33, 0.47, 1.0, alpha) if card == "blue" else Color(1, 0.15, 0.25, alpha)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-6, 0, 12, 4), Color("#3a3f55"))
	draw_rect(Rect2(-6, _height - 4, 12, 4), Color("#3a3f55"))
	draw_rect(Rect2(-4, 0, 8, _height), _laser(0.1))
	for i in 3:
		var a := 0.55 + 0.45 * sin(_t * 23.0 + i * 2.0)
		var x := -3.0 + i * 3.0
		draw_line(Vector2(x, 4), Vector2(x, _height - 4), _laser(a), 1.0)
	draw_rect(Rect2(-2, 1, 4, 2), _laser(1.0))

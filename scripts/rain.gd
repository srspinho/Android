extends CanvasLayer
## Chuva ácida caindo na frente do cenário (em coordenadas de tela).

const DROPS := 110

var _drops: Array[Vector3] = []  # x, y, velocidade
var _canvas: Node2D


func _ready() -> void:
	layer = 5
	_canvas = Node2D.new()
	add_child(_canvas)
	_canvas.draw.connect(_on_draw)
	var size := get_viewport().get_visible_rect().size
	for i in DROPS:
		_drops.append(Vector3(randf() * size.x, randf() * size.y, randf_range(300, 480)))


func _process(delta: float) -> void:
	var size := get_viewport().get_visible_rect().size
	for i in _drops.size():
		var d := _drops[i]
		d.y += d.z * delta
		d.x -= d.z * 0.15 * delta
		if d.y > size.y:
			d = Vector3(randf() * (size.x + 40), -8, d.z)
		_drops[i] = d
	_canvas.queue_redraw()


func _on_draw() -> void:
	for d in _drops:
		_canvas.draw_line(Vector2(d.x, d.y), Vector2(d.x + 1.2, d.y - 7), Color(0.6, 0.85, 1.0, 0.28), 1.0)

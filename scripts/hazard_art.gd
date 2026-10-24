extends Node2D
## Desenha os perigos animados: lodo tóxico (~) e trilho energizado (^).

const T := 16

var main

var _cells: Array[Vector3i] = []  # x, y, tipo (0 = lodo, 1 = trilho)
var _t := 0.0


func _ready() -> void:
	for y in main.rows:
		for x in main.cols:
			var c: String = main.char_at(x, y)
			if c == "~":
				_cells.append(Vector3i(x, y, 0))
			elif c == "^":
				_cells.append(Vector3i(x, y, 1))


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	for cell in _cells:
		var o := Vector2(cell.x * T, cell.y * T)
		if cell.z == 0:
			_sludge(o, cell.x)
		else:
			_rail(o)


func _sludge(o: Vector2, x: int) -> void:
	draw_rect(Rect2(o + Vector2(0, 4), Vector2(T, T - 4)), Color("#0f3d1a"))
	var pts := PackedVector2Array()
	for i in 5:
		var px := i * 4.0
		pts.append(o + Vector2(px, 5 + sin(_t * 3.0 + (x * T + px) * 0.4) * 1.5))
	draw_polyline(pts, Color("#39ff14"), 1.0)
	var b := fmod(_t * 0.8 + x * 0.37, 1.0)
	draw_circle(o + Vector2(4 + (x % 3) * 4, 14 - b * 9), 1.0, Color("#7dff5a", 1.0 - b))


func _rail(o: Vector2) -> void:
	draw_rect(Rect2(o + Vector2(0, 8), Vector2(T, 8)), Color("#11131c"))
	draw_rect(Rect2(o + Vector2(0, 10), Vector2(T, 2)), Color("#8890a0"))
	var pts := PackedVector2Array()
	var n := int(_t * 20.0) * 31 + int(o.x)
	for i in 5:
		pts.append(o + Vector2(i * 4.0, 6 + ((n * (i + 3)) % 7)))
	draw_polyline(pts, Color("#ffe66b", 0.8), 1.0)
	draw_rect(Rect2(o + Vector2(0, 2), Vector2(T, 12)), Color("#00f0ff", 0.06))

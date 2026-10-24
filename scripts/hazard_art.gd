extends Node2D
## Desenha os perigos animados: lodo tóxico (~) e trilho energizado (^).

const TILES := preload("res://art/tiles.png")
const T := 16
const SLUDGE0 := 8
const RAIL0 := 12

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
		var index: int
		if cell.z == 0:
			index = SLUDGE0 + (int(_t * 5.0) + cell.x) % 4
		else:
			index = RAIL0 + (int(_t * 14.0) + cell.x) % 2
		draw_texture_rect_region(TILES, Rect2(cell.x * T, cell.y * T, T, T), Rect2(index * T, 0, T, T))

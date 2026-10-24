extends Node2D
## Desenha as partes paradas do mapa (blocos, plataformas, escadas,
## postes e letreiros). É desenhado uma vez só.

const T := 16

const C_BLOCK := Color("#16122b")
const C_BLOCK_DARK := Color("#100c20")
const C_EDGE := Color("#00e5ff")
const C_EDGE_DIM := Color("#4b2a7a")
const C_METAL := Color("#2b2f45")
const C_YELLOW := Color("#ffd000")
const C_PINK := Color("#ff2bd6")

var main


func _draw() -> void:
	_draw_interiors()
	for y in main.rows:
		for x in main.cols:
			var r := Rect2(x * T, y * T, T, T)
			match main.char_at(x, y):
				"#":
					_block(x, y, r)
				"=":
					_metal(r)
				"-":
					_one_way(r)
				"H":
					_ladder(r)
				"L":
					_lamp(r)
				"M":
					_metro_logo(r)
	for s in main.level.SIGNS:
		_sign(s)


## Áreas cobertas (como o subsolo do metrô) ganham parede de túnel em vez
## de mostrar o céu da cidade.
func _draw_interiors() -> void:
	for x in main.cols:
		var covered := false
		for y in main.rows:
			if main.char_at(x, y) == "#":
				covered = true
				continue
			var walled: bool = main.is_solid_cell(x - 1, y) and main.is_solid_cell(x + 1, y)
			if covered or walled:
				_tunnel_wall(x, y, Rect2(x * T, y * T, T, T))


func _tunnel_wall(x: int, y: int, r: Rect2) -> void:
	draw_rect(r, Color("#0e0a1e"))
	# Azulejos
	draw_line(r.position + Vector2(0, 7.5), r.position + Vector2(T, 7.5), Color("#171230"), 1.0)
	draw_line(r.position + Vector2(7.5 + (y % 2) * 4, 0), r.position + Vector2(7.5 + (y % 2) * 4, 8), Color("#171230"), 1.0)
	# Faixa amarela da Linha 4 na altura dos olhos
	if main.char_at(x, y + 2) == "#" and not main.is_solid_cell(x, y + 1):
		draw_rect(Rect2(r.position + Vector2(0, 6), Vector2(T, 3)), Color(C_YELLOW, 0.35))
	# Pilares
	if x % 12 == 0:
		draw_rect(Rect2(r.position + Vector2(3, 0), Vector2(10, T)), Color("#151027"))
		draw_line(r.position + Vector2(3.5, 0), r.position + Vector2(3.5, T), Color("#241b45"), 1.0)
	# Luminárias logo abaixo do teto
	if main.char_at(x, y - 1) == "#" and x % 5 == 2:
		draw_rect(Rect2(r.position + Vector2(2, 0), Vector2(12, 2)), C_EDGE)
		draw_colored_polygon(PackedVector2Array([
			r.position + Vector2(2, 2), r.position + Vector2(14, 2),
			r.position + Vector2(22, 40), r.position + Vector2(-6, 40)]), Color(C_EDGE, 0.05))


func _block(x: int, y: int, r: Rect2) -> void:
	draw_rect(r, C_BLOCK)
	# Textura simples de concreto
	var h := (x * 7 + y * 13) % 5
	if h == 0:
		draw_rect(Rect2(r.position + Vector2(3, 4), Vector2(5, 3)), C_BLOCK_DARK)
	elif h == 2:
		draw_rect(Rect2(r.position + Vector2(9, 9), Vector2(4, 4)), C_BLOCK_DARK)
	# Bordas expostas: topo em neon ciano, laterais e base em roxo
	if not main.is_solid_cell(x, y - 1):
		draw_rect(Rect2(r.position, Vector2(T, 2)), Color("#2d2552"))
		draw_line(r.position + Vector2(0, 0.5), r.position + Vector2(T, 0.5), C_EDGE, 1.0)
	if not main.is_solid_cell(x, y + 1):
		draw_line(r.position + Vector2(0, T - 0.5), r.position + Vector2(T, T - 0.5), C_EDGE_DIM, 1.0)
	if not main.is_solid_cell(x - 1, y):
		draw_line(r.position + Vector2(0.5, 0), r.position + Vector2(0.5, T), C_EDGE_DIM, 1.0)
	if not main.is_solid_cell(x + 1, y):
		draw_line(r.position + Vector2(T - 0.5, 0), r.position + Vector2(T - 0.5, T), C_EDGE_DIM, 1.0)


func _metal(r: Rect2) -> void:
	draw_rect(r, C_METAL)
	draw_rect(Rect2(r.position, Vector2(T, 3)), Color("#11131c"))
	for i in 4:
		draw_rect(Rect2(r.position + Vector2(i * 4, 0), Vector2(2, 3)), C_YELLOW)
	draw_rect(Rect2(r.position + Vector2(2, 7), Vector2(2, 2)), Color("#8890a0"))
	draw_rect(Rect2(r.position + Vector2(12, 7), Vector2(2, 2)), Color("#8890a0"))


func _one_way(r: Rect2) -> void:
	draw_rect(Rect2(r.position, Vector2(T, 4)), Color("#3a3f5c"))
	draw_line(r.position + Vector2(0, 0.5), r.position + Vector2(T, 0.5), C_PINK, 1.0)
	draw_line(r.position + Vector2(4, 4), r.position + Vector2(8, 9), Color("#2b2f45"), 1.0)
	draw_line(r.position + Vector2(12, 4), r.position + Vector2(8, 9), Color("#2b2f45"), 1.0)


func _ladder(r: Rect2) -> void:
	var rail := Color("#6a7090")
	draw_rect(Rect2(r.position + Vector2(3, 0), Vector2(2, T)), rail)
	draw_rect(Rect2(r.position + Vector2(11, 0), Vector2(2, T)), rail)
	for i in 4:
		draw_rect(Rect2(r.position + Vector2(3, 2 + i * 4), Vector2(10, 1)), Color("#9aa4b8"))


func _lamp(r: Rect2) -> void:
	var base := r.position + Vector2(T / 2.0, T)
	draw_rect(Rect2(base + Vector2(-1, -46), Vector2(2, 46)), Color("#2b2f45"))
	draw_rect(Rect2(base + Vector2(-1, -46), Vector2(9, 2)), Color("#2b2f45"))
	draw_rect(Rect2(base + Vector2(4, -44), Vector2(6, 2)), C_EDGE)
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(4, -42), base + Vector2(10, -42),
		base + Vector2(24, 0), base + Vector2(-10, 0)]), Color(C_EDGE, 0.07))


func _metro_logo(r: Rect2) -> void:
	var box := Rect2(r.position + Vector2(1, 1), Vector2(14, 14))
	draw_rect(box, C_YELLOW)
	draw_rect(box, Color("#11131c"), false, 1.0)
	draw_string(ThemeDB.fallback_font, box.position + Vector2(0, 12), "4", HORIZONTAL_ALIGNMENT_CENTER, 14, 13, Color("#11131c"))


## Letreiro de neon: {"pos": Vector2i(célula), "text": "...", "color": "rrggbb", "size": 12}
func _sign(s: Dictionary) -> void:
	var font := ThemeDB.fallback_font
	var size: int = s.get("size", 12)
	var color := Color(s.get("color", "ff2bd6"))
	var pos := Vector2(s["pos"]) * T + Vector2(0, size)
	var width := font.get_string_size(s["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_rect(Rect2(pos + Vector2(-4, -size - 1), Vector2(width + 8, size + 6)), Color("#07040f"))
	draw_rect(Rect2(pos + Vector2(-4, -size - 1), Vector2(width + 8, size + 6)), Color(color, 0.6), false, 1.0)
	draw_string(font, pos + Vector2(1, 1), s["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(color, 0.35))
	draw_string(font, pos, s["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

extends RefCounted
## Fonte pixelada 5x7 com acentos (imagem gerada por tools/gen_art.py).
## Escreve sempre em maiúsculas, como nos jogos de 1993.

const CHARS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 !?.,:;-–+/()%'\"*·→←xÁÀÂÃÉÊÍÓÔÕÚÇ"
const ADVANCE := 6
const LINE_HEIGHT := 11

static var _tex: Texture2D


## Largura em pixels da linha mais longa do texto.
static func width(text: String, scale := 1) -> int:
	var longest := 0
	for line in text.split("\n"):
		longest = maxi(longest, line.length())
	return longest * ADVANCE * scale - scale


## Desenha o texto com o canto superior esquerdo das letras em `pos`.
static func draw(ci: CanvasItem, pos: Vector2, text: String, color: Color, scale := 1, shadow := true) -> void:
	if shadow:
		_draw_raw(ci, pos + Vector2(scale, scale), text, Color(0, 0, 0, color.a), scale)
	_draw_raw(ci, pos, text, color, scale)


## Desenha cada linha centralizada em `center_x`.
static func draw_centered(ci: CanvasItem, center_x: float, y: float, text: String, color: Color, scale := 1) -> void:
	for line in text.split("\n"):
		draw(ci, Vector2(roundf(center_x - width(line, scale) / 2.0), y), line, color, scale)
		y += LINE_HEIGHT * scale


static func _draw_raw(ci: CanvasItem, pos: Vector2, text: String, color: Color, scale: int) -> void:
	if _tex == null:
		_tex = load("res://art/font.png")
	var y := pos.y
	for line in text.to_upper().split("\n"):
		var x := pos.x
		for ch in line:
			if ch != " ":
				var idx := CHARS.find(ch)
				if idx < 0:
					idx = CHARS.find("?")
				ci.draw_texture_rect_region(_tex, Rect2(x, y - 2 * scale, 6 * scale, 10 * scale), Rect2(idx * 6, 0, 6, 10), color)
			x += ADVANCE * scale
		y += LINE_HEIGHT * scale

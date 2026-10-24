extends CanvasLayer
## Interface: energia, créditos, itens, avisos e telas de fim.

const C_CYAN := Color("#00f0ff")
const C_PINK := Color("#ff2bd6")
const C_YELLOW := Color("#ffd000")
const C_OUTLINE := Color("#07040f")

var main

var _canvas: Node2D
var _banner_title := ""
var _banner_sub := ""
var _banner_t := 0.0
var _msg := ""
var _msg_t := 0.0
var _overlay_title := ""
var _overlay_sub := ""
var _overlay_t := -1.0


func _ready() -> void:
	layer = 10
	_canvas = Node2D.new()
	add_child(_canvas)
	_canvas.draw.connect(_on_draw)


func show_banner(title: String, subtitle: String) -> void:
	_banner_title = title
	_banner_sub = subtitle
	_banner_t = 4.0


func show_message(text: String) -> void:
	_msg = text
	_msg_t = 2.5


func show_overlay(title: String, subtitle: String) -> void:
	_overlay_title = title
	_overlay_sub = subtitle
	_overlay_t = 0.0


## Segundos desde que a tela de fim apareceu (-1 se não há tela).
func overlay_time() -> float:
	return _overlay_t


func _process(delta: float) -> void:
	_banner_t -= delta
	_msg_t -= delta
	if _overlay_t >= 0.0:
		_overlay_t += delta
	_canvas.queue_redraw()


func _text(pos: Vector2, text: String, size: int, color: Color, width := -1.0, align := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	var font := ThemeDB.fallback_font
	_canvas.draw_multiline_string_outline(font, pos, text, align, width, size, -1, 3, Color(C_OUTLINE, color.a))
	_canvas.draw_multiline_string(font, pos, text, align, width, size, -1, color)


func _on_draw() -> void:
	var size := _canvas.get_viewport_rect().size
	var p = main.player

	# Energia
	_text(Vector2(10, 17), "ENERGIA", 9, C_CYAN)
	for i in p.max_hp:
		var r := Rect2(54 + i * 9, 9, 7, 9)
		_canvas.draw_rect(r, C_PINK if i < p.hp else Color(C_PINK, 0.15))
	# Créditos
	_text(Vector2(size.x - 170, 17), "CRÉDITOS %06d" % main.get_score(), 10, C_YELLOW, 160, HORIZONTAL_ALIGNMENT_RIGHT)
	# Itens
	var y := 24.0
	if p.has_keycard:
		_canvas.draw_rect(Rect2(10, y, 12, 8), Color("#ff3355"))
		_canvas.draw_rect(Rect2(10, y + 2, 12, 2), C_OUTLINE)
		_text(Vector2(26, y + 8), "CARTÃO", 8, Color("#ff3355"))
		y += 12
	if p.rapid_fire > 0.0:
		_text(Vector2(10, y + 8), "TURBO %d" % ceili(p.rapid_fire), 8, C_CYAN)

	if _banner_t > 0.0:
		var a := clampf(_banner_t, 0.0, 1.0)
		_text(Vector2(0, 80), _banner_title, 18, Color(C_YELLOW, a), size.x, HORIZONTAL_ALIGNMENT_CENTER)
		_text(Vector2(0, 98), _banner_sub, 10, Color(C_CYAN, a), size.x, HORIZONTAL_ALIGNMENT_CENTER)
	if _msg_t > 0.0:
		_text(Vector2(0, 52), _msg, 11, Color(1, 1, 1, clampf(_msg_t, 0.0, 1.0)), size.x, HORIZONTAL_ALIGNMENT_CENTER)

	if _overlay_t >= 0.0:
		var k := clampf(_overlay_t * 2.0, 0.0, 1.0)
		_canvas.draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.0, 0.06, 0.75 * k))
		_text(Vector2(0, size.y * 0.42), _overlay_title, 26, Color(C_PINK, k), size.x, HORIZONTAL_ALIGNMENT_CENTER)
		_text(Vector2(0, size.y * 0.42 + 26), _overlay_sub, 11, Color(C_CYAN, k), size.x, HORIZONTAL_ALIGNMENT_CENTER)

extends CanvasLayer
## Interface no estilo Duke Nukem II: painel lateral (itens, retrato, radar,
## fase) e barra inferior (pontos, arma, energia) com moldura de canos.

const PixelFont := preload("res://scripts/pixel_font.gd")
const PORTRAIT := preload("res://art/portrait.png")
const ITEMS := preload("res://art/items.png")

const PANEL_W := 56
const BAR_H := 30
## Distância (em pixels do mundo) que cabe do centro até a borda do radar.
const RADAR_RANGE := 160.0

const C_BLUE := Color("#5478fc")
const C_GREEN := Color("#54fc54")
const C_RED := Color("#fc5454")
const C_CYAN := Color("#54fcfc")
const C_PINK := Color("#fc54fc")
const C_YELLOW := Color("#fcfc54")
const C_PIPE_LIGHT := Color("#c4c4c4")
const C_PIPE := Color("#8c8c8c")
const C_PIPE_DARK := Color("#545454")
const C_METAL := Color("#3c3c48")

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


func _on_draw() -> void:
	var size := _canvas.get_viewport_rect().size
	var play := Rect2(0, 0, size.x - PANEL_W, size.y - BAR_H)
	_draw_play_texts(play)
	_draw_side_panel(Rect2(play.end.x, 0, PANEL_W, size.y))
	_draw_bottom_bar(Rect2(0, play.end.y, play.size.x, BAR_H))


# --- Peças da moldura -------------------------------------------------------

## Moldura de canos de metal.
func _frame(r: Rect2) -> void:
	_canvas.draw_rect(r, C_METAL)
	for i in 3:
		var c: Color = [C_PIPE_LIGHT, C_PIPE, C_PIPE_DARK][i]
		_canvas.draw_rect(Rect2(r.position + Vector2(i, i), Vector2(r.size.x - i * 2, 1)), c)
		_canvas.draw_rect(Rect2(r.position + Vector2(i, i), Vector2(1, r.size.y - i * 2)), c)
		var c2: Color = [C_PIPE_DARK, C_PIPE, C_PIPE_LIGHT][i]
		_canvas.draw_rect(Rect2(r.position.x + i, r.end.y - 1 - i, r.size.x - i * 2, 1), c2)
		_canvas.draw_rect(Rect2(r.end.x - 1 - i, r.position.y + i, 1, r.size.y - i * 2), c2)


## Caixa rebaixada (fundo preto com sombra).
func _box(r: Rect2) -> void:
	_canvas.draw_rect(r, Color.BLACK)
	_canvas.draw_rect(Rect2(r.position - Vector2.ONE, Vector2(r.size.x + 2, 1)), C_PIPE_DARK)
	_canvas.draw_rect(Rect2(r.position - Vector2.ONE, Vector2(1, r.size.y + 2)), C_PIPE_DARK)
	_canvas.draw_rect(Rect2(r.position.x - 1, r.end.y, r.size.x + 2, 1), C_PIPE_LIGHT)
	_canvas.draw_rect(Rect2(r.end.x, r.position.y - 1, 1, r.size.y + 2), C_PIPE_LIGHT)


## Título de seção: faixa colorida com setas e texto, como "→ ITEMS ←".
func _label(x: float, y: float, w: float, text: String, color: Color) -> void:
	_canvas.draw_rect(Rect2(x + 3, y + 3, w - 6, 1), Color(color, 0.6))
	var tw := PixelFont.width(text)
	var tx := roundf(x + (w - tw) / 2.0)
	_canvas.draw_rect(Rect2(tx - 3, y, tw + 6, 8), C_METAL)
	PixelFont.draw(_canvas, Vector2(tx, y), text, color)
	_canvas.draw_rect(Rect2(x + 3, y + 1, 3, 5), color)
	_canvas.draw_rect(Rect2(x + w - 6, y + 1, 3, 5), color)


# --- Painel lateral ---------------------------------------------------------

func _draw_side_panel(r: Rect2) -> void:
	var p = main.player
	_frame(r)
	var x := r.position.x
	_label(x, 5, PANEL_W, "ITENS", C_BLUE)
	var items := Rect2(x + 6, 15, PANEL_W - 12, 20)
	_box(items)
	# Cartões à esquerda (vermelho e azul), turbo à direita
	var slot := 0
	for card in [["red", 1], ["blue", 4]]:
		if p.keycards.get(card[0], false):
			_canvas.draw_texture_rect_region(ITEMS, Rect2(items.position + Vector2(1 + slot * 11, 2), Vector2(16, 16)), Rect2(card[1] * 16, 0, 16, 16))
			slot += 1
	var show_turbo: bool = p.rapid_fire > 3.0 or (p.rapid_fire > 0.0 and int(p.rapid_fire * 4.0) % 2 == 0)
	if show_turbo:
		_canvas.draw_texture_rect_region(ITEMS, Rect2(items.position + Vector2(24, 2), Vector2(16, 16)), Rect2(32, 0, 16, 16))

	var face := Rect2(x + (PANEL_W - 34) / 2.0, 41, 34, 34)
	_box(face)
	_canvas.draw_texture(PORTRAIT, face.position + Vector2.ONE, Color(1, 0.5, 0.5) if p.hp <= 2 and Engine.get_process_frames() / 15 % 2 == 0 else Color.WHITE)

	_label(x, 81, PANEL_W, "RADAR", C_GREEN)
	var radar := Rect2(x + 6, 91, PANEL_W - 12, PANEL_W - 12)
	_box(radar)
	_draw_radar(radar, p.global_position)

	var ly := radar.end.y + 7
	_label(x, ly, PANEL_W, "FASE", C_RED)
	var lv := Rect2(x + 14, ly + 10, PANEL_W - 28, 20)
	_box(lv)
	PixelFont.draw_centered(_canvas, lv.get_center().x, lv.position.y + 3, str(main.level_number()), C_BLUE, 2)


func _draw_radar(r: Rect2, center: Vector2) -> void:
	var k := (r.size.x / 2.0) / RADAR_RANGE
	var mid := r.get_center()
	_canvas.draw_rect(Rect2(r.position.x, mid.y, r.size.x, 1), Color(C_GREEN, 0.15))
	_canvas.draw_rect(Rect2(mid.x, r.position.y, 1, r.size.y), Color(C_GREEN, 0.15))
	for e in main.get_tree().get_nodes_in_group("enemies"):
		var d: Vector2 = (e.global_position - center) * k
		if absf(d.x) < r.size.x / 2.0 - 1 and absf(d.y) < r.size.y / 2.0 - 1:
			_canvas.draw_rect(Rect2((mid + d).floor(), Vector2(2, 2)), C_RED)
	if Engine.get_process_frames() / 20 % 2 == 0:
		_canvas.draw_rect(Rect2(mid.floor() - Vector2.ONE, Vector2(2, 2)), Color.WHITE)


# --- Barra inferior ---------------------------------------------------------

func _draw_bottom_bar(r: Rect2) -> void:
	var p = main.player
	_frame(r)
	var w1 := floorf(r.size.x * 0.4)
	var w2 := floorf(r.size.x * 0.22)
	var w3 := r.size.x - w1 - w2
	var y := r.position.y
	var x2 := r.position.x + w1
	var x3 := x2 + w2
	for x in [x2, x3]:
		_canvas.draw_rect(Rect2(x - 1, y + 2, 1, BAR_H - 4), C_PIPE_DARK)
		_canvas.draw_rect(Rect2(x, y + 2, 1, BAR_H - 4), C_PIPE_LIGHT)

	_label(r.position.x, y + 3, w1, "PONTOS", C_BLUE)
	var sbox := Rect2(r.position.x + 6, y + 12, w1 - 12, 15)
	_box(sbox)
	var score := "%07d" % main.get_score()
	PixelFont.draw(_canvas, Vector2(sbox.end.x - PixelFont.width(score, 2) - 2, sbox.position.y + 1), score, C_BLUE, 2)

	_label(x2, y + 3, w2, "ARMA", C_RED)
	var wbox := Rect2(x2 + 6, y + 12, w2 - 12, 15)
	_box(wbox)
	_draw_blaster(wbox.position + Vector2(3, 5), p.rapid_fire > 0.0)
	if p.rapid_fire > 0.0:
		var h := ceilf(13.0 * p.rapid_fire / 15.0)
		_canvas.draw_rect(Rect2(wbox.end.x - 5, wbox.end.y - 1 - h, 3, h), C_CYAN)

	_label(x3, y + 3, w3, "ENERGIA", C_GREEN)
	var hbox := Rect2(x3 + 6, y + 12, w3 - 12, 15)
	_box(hbox)
	var seg := floorf((hbox.size.x - 2) / p.max_hp)
	for i in p.max_hp:
		var cell := Rect2(hbox.position.x + 2 + i * seg, hbox.position.y + 2, seg - 2, 11)
		if i < p.hp:
			_canvas.draw_rect(cell, Color("#00a800"))
			_canvas.draw_rect(Rect2(cell.position, Vector2(cell.size.x, 2)), C_GREEN)
		else:
			_canvas.draw_rect(cell, Color("#103010"))


func _draw_blaster(o: Vector2, turbo: bool) -> void:
	_canvas.draw_rect(Rect2(o + Vector2(0, 1), Vector2(16, 4)), C_PIPE)
	_canvas.draw_rect(Rect2(o + Vector2(0, 1), Vector2(16, 1)), C_PIPE_LIGHT)
	_canvas.draw_rect(Rect2(o + Vector2(2, 5), Vector2(3, 3)), C_PIPE_DARK)
	_canvas.draw_rect(Rect2(o + Vector2(16, 2), Vector2(3, 2)), C_CYAN if turbo else C_RED)
	_canvas.draw_rect(Rect2(o + Vector2(6, 0), Vector2(6, 1)), C_PIPE_DARK)


# --- Textos na área de jogo -------------------------------------------------

## Barra de vida do chefe, numa linha fina no topo da tela, quando ele está perto.
func _draw_boss_bar(play: Rect2) -> void:
	if not main.boss_alive():
		return
	var b = main.boss
	if b.global_position.distance_to(main.player.global_position) > b.active_range:
		return
	var label: String = b.display_name
	var lw := PixelFont.width(label)
	var w := minf(play.size.x - lw - 30, 200.0)
	var x := roundf(play.get_center().x - (lw + 6 + w) / 2.0)
	_canvas.draw_rect(Rect2(x - 4, 0, lw + w + 14, 10), Color(0, 0, 0, 0.6))
	PixelFont.draw(_canvas, Vector2(x, 2), label, C_GREEN)
	var r := Rect2(x + lw + 6, 3, w, 4)
	_box(r)
	_canvas.draw_rect(Rect2(r.position, Vector2(r.size.x * b.hp / b.max_hp, r.size.y)), Color("#00a800"))
	_canvas.draw_rect(Rect2(r.position, Vector2(r.size.x * b.hp / b.max_hp, 1)), C_GREEN)


func _draw_play_texts(play: Rect2) -> void:
	var cx := play.get_center().x
	_draw_boss_bar(play)
	if _banner_t > 0.0:
		var a := clampf(_banner_t, 0.0, 1.0)
		var lines := _banner_sub.count("\n") + 1
		_canvas.draw_rect(Rect2(play.position.x + 8, 24, play.size.x - 16, 34 + lines * PixelFont.LINE_HEIGHT), Color(0, 0, 0, 0.6 * a))
		PixelFont.draw_centered(_canvas, cx, 30, _banner_title, Color(C_YELLOW, a), 2)
		PixelFont.draw_centered(_canvas, cx, 52, _banner_sub, Color(C_CYAN, a))
	if _msg_t > 0.0:
		var ma := clampf(_msg_t, 0.0, 1.0)
		var mw := PixelFont.width(_msg) + 12
		_canvas.draw_rect(Rect2(roundf(cx - mw / 2.0), 13, mw, 15), Color(0, 0, 0, 0.7 * ma))
		PixelFont.draw_centered(_canvas, cx, 17, _msg, Color(1, 1, 1, ma))
	if _overlay_t >= 0.0:
		var k := clampf(_overlay_t * 2.0, 0.0, 1.0)
		_canvas.draw_rect(play, Color(0.02, 0.0, 0.06, 0.75 * k))
		PixelFont.draw_centered(_canvas, cx, play.size.y * 0.35, _overlay_title, Color(C_PINK, k), 2)
		PixelFont.draw_centered(_canvas, cx, play.size.y * 0.35 + 24, _overlay_sub, Color(C_CYAN, k))

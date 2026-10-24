extends CanvasLayer
## Controles na tela para celular: direcional à esquerda, PULO e TIRO à direita.
## Aparecem só no celular (ou rodando o jogo com o argumento -- --touch).

const PixelFont := preload("res://scripts/pixel_font.gd")
const HudScript := preload("res://scripts/hud.gd")
## A área de toque é um pouco maior que o desenho do botão.
const TOUCH_MARGIN := 5.0

var _buttons: Array[Dictionary] = []
var _visual: Node2D


func _ready() -> void:
	layer = 20
	var wanted := OS.has_feature("mobile") or "--touch" in OS.get_cmdline_user_args()
	if not wanted:
		return
	_add("move_left", "left", 13)
	_add("move_right", "right", 13)
	_add("move_up", "up", 12)
	_add("move_down", "down", 12)
	_add("shoot", "TIRO", 16)
	_add("jump", "PULO", 18)
	_visual = Node2D.new()
	add_child(_visual)
	_visual.draw.connect(_on_draw)
	get_viewport().size_changed.connect(_layout)
	_layout()


func _add(action: String, label: String, radius: float) -> void:
	var b := TouchScreenButton.new()
	var shape := CircleShape2D.new()
	shape.radius = radius + TOUCH_MARGIN
	b.shape = shape
	b.shape_centered = false
	b.action = action
	b.passby_press = true
	add_child(b)
	_buttons.append({"node": b, "label": label, "radius": radius})


func _layout() -> void:
	var s := get_viewport().get_visible_rect().size
	var play_right := s.x - HudScript.PANEL_W
	var play_bottom := s.y - HudScript.BAR_H
	var pad := Vector2(40, play_bottom - 34)
	var spots := [
		pad + Vector2(-23, 0), pad + Vector2(23, 0), pad + Vector2(0, -22), pad + Vector2(0, 22),
		Vector2(play_right - 66, play_bottom - 18), Vector2(play_right - 26, play_bottom - 40),
	]
	for i in _buttons.size():
		_buttons[i]["node"].position = spots[i]


func _process(_delta: float) -> void:
	if _visual:
		_visual.queue_redraw()


func _on_draw() -> void:
	for b in _buttons:
		var node: TouchScreenButton = b["node"]
		var c: Vector2 = node.position
		var r: float = b["radius"]
		var col := Color("#fc54fc") if b["label"] == "PULO" else Color("#54fcfc")
		_visual.draw_circle(c, r, Color(col, 0.35 if node.is_pressed() else 0.12))
		_visual.draw_arc(c, r, 0, TAU, 24, Color(col, 0.75), 1.0)
		match b["label"]:
			"left":
				_arrow(c, Vector2.LEFT, col)
			"right":
				_arrow(c, Vector2.RIGHT, col)
			"up":
				_arrow(c, Vector2.UP, col)
			"down":
				_arrow(c, Vector2.DOWN, col)
			_:
				PixelFont.draw_centered(_visual, c.x, c.y - 3, b["label"], Color(col, 0.9))


func _arrow(c: Vector2, d: Vector2, col: Color) -> void:
	var side := Vector2(-d.y, d.x)
	_visual.draw_colored_polygon(PackedVector2Array([c + d * 5, c - d * 3 + side * 4, c - d * 3 - side * 4]), Color(col, 0.85))

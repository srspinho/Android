extends CanvasLayer
## Controles na tela para celular: direcional à esquerda, PULO e TIRO à direita.
## Aparecem só em telas de toque (ou rodando o jogo com o argumento -- --touch).

var _buttons: Array[Dictionary] = []
var _visual: Node2D


func _ready() -> void:
	layer = 20
	var wanted := DisplayServer.is_touchscreen_available() or OS.has_feature("mobile") \
		or "--touch" in OS.get_cmdline_user_args()
	if not wanted:
		return
	_add("move_left", "left", 22)
	_add("move_right", "right", 22)
	_add("move_up", "up", 20)
	_add("move_down", "down", 20)
	_add("shoot", "TIRO", 28)
	_add("jump", "PULO", 30)
	_visual = Node2D.new()
	add_child(_visual)
	_visual.draw.connect(_on_draw)
	get_viewport().size_changed.connect(_layout)
	_layout()


func _add(action: String, label: String, radius: float) -> void:
	var b := TouchScreenButton.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	b.shape = shape
	b.shape_centered = false
	b.action = action
	b.passby_press = true
	add_child(b)
	_buttons.append({"node": b, "label": label, "radius": radius})


func _layout() -> void:
	var s := get_viewport().get_visible_rect().size
	var pad := Vector2(78, s.y - 74)
	var spots := [
		pad + Vector2(-38, 0), pad + Vector2(38, 0), pad + Vector2(0, -36), pad + Vector2(0, 36),
		Vector2(s.x - 124, s.y - 48), Vector2(s.x - 54, s.y - 82),
	]
	for i in _buttons.size():
		_buttons[i]["node"].position = spots[i]


func _process(_delta: float) -> void:
	if _visual:
		_visual.queue_redraw()


func _on_draw() -> void:
	var font := ThemeDB.fallback_font
	for b in _buttons:
		var node: TouchScreenButton = b["node"]
		var c: Vector2 = node.position
		var r: float = b["radius"]
		var pressed := node.is_pressed()
		var col := Color("#ff2bd6") if b["label"] == "PULO" else Color("#00f0ff")
		_visual.draw_circle(c, r, Color(col, 0.28 if pressed else 0.1))
		_visual.draw_arc(c, r, 0, TAU, 32, Color(col, 0.7), 1.5)
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
				_visual.draw_string(font, c + Vector2(-r, 4), b["label"], HORIZONTAL_ALIGNMENT_CENTER, r * 2, 11, Color(col, 0.9))


func _arrow(c: Vector2, d: Vector2, col: Color) -> void:
	var side := Vector2(-d.y, d.x)
	_visual.draw_colored_polygon(PackedVector2Array([c + d * 8, c - d * 5 + side * 7, c - d * 5 - side * 7]), Color(col, 0.8))

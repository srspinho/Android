extends CanvasLayer
## Controles na tela para celular: direcional analógico de 8 direções à
## esquerda (arrastar o dedo na diagonal permite andar e mirar para cima ao
## mesmo tempo) e os botões PULO e TIRO à direita.
## Aparecem só no celular (ou rodando o jogo com o argumento -- --touch).

const PixelFont := preload("res://scripts/pixel_font.gd")
const HudScript := preload("res://scripts/hud.gd")
## A área de toque dos botões é um pouco maior que o desenho.
const TOUCH_MARGIN := 5.0
const STICK_RADIUS := 22.0
## Até onde o dedo pode começar o toque e ainda pegar o direcional.
const STICK_ZONE := 46.0
const DEAD_ZONE := 5.0
## Direções de cada um dos 8 setores, começando pela direita e girando no
## sentido horário (o eixo y da tela aponta para baixo).
const SECTORS := [
	["move_right"], ["move_right", "move_down"], ["move_down"], ["move_down", "move_left"],
	["move_left"], ["move_left", "move_up"], ["move_up"], ["move_up", "move_right"],
]
const STICK_ACTIONS := ["move_left", "move_right", "move_up", "move_down"]

var _buttons: Array[Dictionary] = []
var _visual: Node2D
var _active := false
var _stick_center := Vector2.ZERO
var _stick_touch := -1
var _stick_knob := Vector2.ZERO


func _ready() -> void:
	layer = 20
	_active = OS.has_feature("mobile") or "--touch" in OS.get_cmdline_user_args()
	if not _active:
		return
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
	add_child(b)
	_buttons.append({"node": b, "label": label, "radius": radius})


func _layout() -> void:
	var s := get_viewport().get_visible_rect().size
	var play_right := s.x - HudScript.PANEL_W
	var play_bottom := s.y - HudScript.BAR_H
	_stick_center = Vector2(42, play_bottom - 36)
	_buttons[0]["node"].position = Vector2(play_right - 66, play_bottom - 18)
	_buttons[1]["node"].position = Vector2(play_right - 26, play_bottom - 40)


func _input(event: InputEvent) -> void:
	if not _active:
		return
	if event is InputEventScreenTouch:
		if event.pressed and _stick_touch < 0 and event.position.distance_to(_stick_center) <= STICK_ZONE:
			_stick_touch = event.index
			_update_stick(event.position)
		elif not event.pressed and event.index == _stick_touch:
			_stick_touch = -1
			_update_stick(_stick_center)
	elif event is InputEventScreenDrag and event.index == _stick_touch:
		_update_stick(event.position)


func _update_stick(pos: Vector2) -> void:
	var v := pos - _stick_center
	_stick_knob = v.limit_length(STICK_RADIUS)
	var wanted: Array = []
	if v.length() > DEAD_ZONE:
		var sector := posmod(roundi(v.angle() / (PI / 4.0)), 8)
		wanted = SECTORS[sector]
	for action in STICK_ACTIONS:
		var on: bool = action in wanted
		if on and not Input.is_action_pressed(action):
			Input.action_press(action)
		elif not on and Input.is_action_pressed(action):
			Input.action_release(action)


func _process(_delta: float) -> void:
	if _visual:
		_visual.queue_redraw()


func _on_draw() -> void:
	var cyan := Color("#54fcfc")
	# Direcional: base com setas e o "pino" que segue o dedo
	_visual.draw_circle(_stick_center, STICK_RADIUS + 6, Color(cyan, 0.1))
	_visual.draw_arc(_stick_center, STICK_RADIUS + 6, 0, TAU, 32, Color(cyan, 0.6), 1.0)
	for d in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		_arrow(_stick_center + d * (STICK_RADIUS - 1), d, cyan)
	var knob := _stick_center + _stick_knob
	_visual.draw_circle(knob, 9, Color(cyan, 0.45 if _stick_touch >= 0 else 0.25))
	_visual.draw_arc(knob, 9, 0, TAU, 20, Color(cyan, 0.8), 1.0)

	for b in _buttons:
		var node: TouchScreenButton = b["node"]
		var c: Vector2 = node.position
		var r: float = b["radius"]
		var col := Color("#fc54fc") if b["label"] == "PULO" else cyan
		_visual.draw_circle(c, r, Color(col, 0.35 if node.is_pressed() else 0.12))
		_visual.draw_arc(c, r, 0, TAU, 24, Color(col, 0.75), 1.0)
		PixelFont.draw_centered(_visual, c.x, c.y - 3, b["label"], Color(col, 0.9))


func _arrow(c: Vector2, d: Vector2, col: Color) -> void:
	var side := Vector2(-d.y, d.x)
	_visual.draw_colored_polygon(PackedVector2Array([c + d * 3, c - d * 2 + side * 3, c - d * 2 - side * 3]), Color(col, 0.7))

extends Area2D
## Itens coletáveis e a saída da fase.
##  +  coxinha energética (recupera energia)
##  K  cartão de acesso vermelho
##  W  turbo no blaster (tiro rápido)
##  *  chip de dados (pontos)
##  E  saída da fase

var main
var kind := "*"

var _t := 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	if kind == "E":
		shape.size = Vector2(14, 30)
		cs.position = Vector2(0, -7)
	else:
		shape.size = Vector2(12, 12)
	cs.shape = shape
	add_child(cs)
	body_entered.connect(_on_body_entered)
	_t = position.x * 0.05


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if body != main.player:
		return
	match kind:
		"+":
			body.heal(2)
			main.hud.show_message("Coxinha energética! +2 de energia")
		"K":
			body.has_keycard = true
			main.hud.show_message("Cartão de acesso VERMELHO obtido!")
		"W":
			body.rapid_fire = 15.0
			main.hud.show_message("Turbo no blaster: tiro rápido por 15 s")
		"*":
			main.add_score(250)
		"E":
			main.level_complete()
			return
	main.spawn_fx(global_position, _glow(), 10.0)
	queue_free()


func _glow() -> Color:
	match kind:
		"+":
			return Color("#ffb347")
		"K":
			return Color("#ff3355")
		"W":
			return Color("#00f0ff")
		"E":
			return Color("#39ff14")
	return Color("#c6ff00")


func _draw() -> void:
	if kind == "E":
		_draw_exit()
		return
	var bob := sin(_t * 3.0) * 2.0
	var o := Vector2(0, bob)
	draw_circle(o, 8.0, Color(_glow(), 0.15))
	match kind:
		"+":
			# Coxinha: base redonda e ponta para cima
			draw_colored_polygon(PackedVector2Array([
				o + Vector2(0, -7), o + Vector2(4, -1), o + Vector2(5, 3), o + Vector2(3, 5),
				o + Vector2(-3, 5), o + Vector2(-5, 3), o + Vector2(-4, -1)]), Color("#d98a2b"))
			draw_rect(Rect2(o + Vector2(-2, -2), Vector2(2, 2)), Color("#ffd27f"))
		"K":
			draw_rect(Rect2(o + Vector2(-6, -4), Vector2(12, 8)), Color("#ff3355"))
			draw_rect(Rect2(o + Vector2(-6, -2), Vector2(12, 2)), Color("#1b1035"))
			draw_rect(Rect2(o + Vector2(2, 1), Vector2(3, 2)), Color("#ffd000"))
		"W":
			draw_rect(Rect2(o + Vector2(-4, -6), Vector2(8, 12)), Color("#11131c"))
			draw_rect(Rect2(o + Vector2(-2, -7), Vector2(4, 1)), Color("#8890a0"))
			draw_polyline(PackedVector2Array([o + Vector2(1, -5), o + Vector2(-2, 0), o + Vector2(2, 0), o + Vector2(-1, 5)]), Color("#00f0ff"), 1.0)
		_:
			draw_rect(Rect2(o + Vector2(-4, -4), Vector2(8, 8)), Color("#11131c"))
			draw_rect(Rect2(o + Vector2(-2, -2), Vector2(4, 4)), Color("#c6ff00"))
			for i in 3:
				draw_rect(Rect2(o + Vector2(-3 + i * 3, -6), Vector2(1, 2)), Color("#8890a0"))
				draw_rect(Rect2(o + Vector2(-3 + i * 3, 4), Vector2(1, 2)), Color("#8890a0"))


func _draw_exit() -> void:
	var c := Color("#39ff14")
	var pulse := 0.5 + 0.5 * sin(_t * 4.0)
	draw_rect(Rect2(-9, -24, 18, 32), Color(c, 0.12 + 0.12 * pulse))
	draw_rect(Rect2(-9, -24, 18, 32), c, false, 1.0)
	for i in 4:
		var y := 8.0 - fmod(_t * 20.0 + i * 8.0, 32.0)
		draw_line(Vector2(-6, y), Vector2(6, y), Color(c, 0.6), 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(-20, -28), "SAÍDA", HORIZONTAL_ALIGNMENT_CENTER, 40, 9, c)

extends ParallaxBackground
## Cenário de fundo em camadas: céu roxo, a Torre do Relógio da USP ao longe,
## prédios com janelas acesas e um outdoor holográfico mais perto.

const MIRROR := 1024.0


func _ready() -> void:
	_layer(Vector2.ZERO, 0.0, _draw_sky)
	_layer(Vector2(0.08, 0.02), MIRROR, _draw_far)
	_layer(Vector2(0.25, 0.06), MIRROR, _draw_mid)


func _layer(motion: Vector2, mirror: float, draw_func: Callable) -> void:
	var pl := ParallaxLayer.new()
	pl.motion_scale = motion
	pl.motion_mirroring = Vector2(mirror, 0)
	add_child(pl)
	var canvas := Node2D.new()
	pl.add_child(canvas)
	canvas.draw.connect(draw_func.bind(canvas))


func _draw_sky(c: Node2D) -> void:
	var top := Color("#07021a")
	var horizon := Color("#4a0f5c")
	var bands := 30
	for i in bands:
		var k := float(i) / bands
		c.draw_rect(Rect2(-50, -100 + i * 16, 2200, 17), top.lerp(horizon, k * k))
	c.draw_rect(Rect2(-50, 380, 2200, 400), horizon)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 70:
		c.draw_rect(Rect2(rng.randf() * 1600, rng.randf() * 200, 1, 1), Color(1, 1, 1, rng.randf_range(0.2, 0.7)))
	# Lua neon atrás da poluição
	c.draw_circle(Vector2(470, 70), 34, Color("#ff2bd6", 0.08))
	c.draw_circle(Vector2(470, 70), 22, Color("#ff7ae8", 0.35))


func _draw_far(c: Node2D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	var x := 0.0
	while x < MIRROR:
		var w := rng.randf_range(30, 70)
		var h := rng.randf_range(70, 170)
		_building(c, rng, Rect2(x, 330 - h, w, h + 300), Color("#1a0f38"), 0.12)
		x += w + rng.randf_range(0, 10)
	# Torre do Relógio da USP (Praça do Relógio, Cidade Universitária)
	var tx := 620.0
	c.draw_rect(Rect2(tx - 7, 70, 14, 600), Color("#24164a"))
	c.draw_rect(Rect2(tx - 10, 66, 20, 8), Color("#24164a"))
	c.draw_circle(Vector2(tx, 92), 5, Color("#ffd000", 0.8))
	c.draw_line(Vector2(tx, 92), Vector2(tx, 89), Color("#24164a"), 1.0)
	c.draw_line(Vector2(tx, 92), Vector2(tx + 2, 93), Color("#24164a"), 1.0)
	c.draw_rect(Rect2(tx - 1, 54, 2, 12), Color("#24164a"))
	c.draw_rect(Rect2(tx - 1, 52, 2, 2), Color("#ff3355"))


func _draw_mid(c: Node2D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var x := 0.0
	while x < MIRROR:
		var w := rng.randf_range(40, 90)
		var h := rng.randf_range(50, 140)
		_building(c, rng, Rect2(x, 350 - h, w, h + 300), Color("#120a28"), 0.3)
		if rng.randf() < 0.35:
			# Letreiro vertical de neon
			var col: Color = [Color("#ff2bd6"), Color("#00f0ff"), Color("#ffd000")][rng.randi() % 3]
			c.draw_rect(Rect2(x + 4, 350 - h + 10, 5, 34), Color(col, 0.85))
		x += w + rng.randf_range(4, 24)
	# Outdoor holográfico da corporação vilã
	var b := Rect2(300, 190, 120, 40)
	c.draw_rect(Rect2(b.position.x + 56, b.end.y, 4, 200), Color("#0b0618"))
	c.draw_rect(b, Color("#00f0ff", 0.12))
	c.draw_rect(b, Color("#00f0ff", 0.7), false, 1.0)
	var pts := PackedVector2Array()
	for i in 12:
		pts.append(b.position + Vector2(10 + i * 3, 20 + sin(i * 0.9) * 6))
	c.draw_polyline(pts, Color("#39ff14"), 2.0)
	c.draw_string(ThemeDB.fallback_font, b.position + Vector2(50, 18), "SERPENTIS", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#00f0ff"))
	c.draw_string(ThemeDB.fallback_font, b.position + Vector2(50, 31), "BIOTECH", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#ff2bd6"))


func _building(c: Node2D, rng: RandomNumberGenerator, r: Rect2, color: Color, lit: float) -> void:
	c.draw_rect(r, color)
	var lights := [Color("#00f0ff"), Color("#ff2bd6"), Color("#ffd000"), Color("#b388ff")]
	var wy := r.position.y + 6
	while wy < r.position.y + 260:
		var wx := r.position.x + 4
		while wx < r.end.x - 5:
			if rng.randf() < lit:
				c.draw_rect(Rect2(wx, wy, 3, 2), Color(lights[rng.randi() % lights.size()], 0.7))
			wx += 7
		wy += 8

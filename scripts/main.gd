extends Node2D
## Cena principal: monta a fase a partir do mapa em texto e coordena o jogo
## (pontuação, morte, fim de fase e reinício).

const TILE := 16

## Lista de fases, na ordem em que são jogadas.
const LEVELS := [
	preload("res://levels/fase1_estacao_butanta.gd"),
	preload("res://levels/fase2_instituto_butantan.gd"),
	preload("res://levels/fase3_cidade_universitaria.gd"),
]

## Caracteres do mapa que viram colisão.
const SOLID := "#="
const ONE_WAY := "-"
const LADDER := "H"
const HAZARD := "~^w"

const PlayerScript := preload("res://scripts/player.gd")
const GuardScript := preload("res://scripts/enemy_guard.gd")
const DroneScript := preload("res://scripts/enemy_drone.gd")
const SnakeScript := preload("res://scripts/enemy_snake.gd")
const BossScript := preload("res://scripts/enemy_boss.gd")
const ClockBossScript := preload("res://scripts/enemy_boss_clock.gd")
const PlatformScript := preload("res://scripts/moving_platform.gd")
const PickupScript := preload("res://scripts/pickup.gd")
const DoorScript := preload("res://scripts/door.gd")
const HotdogScript := preload("res://scripts/hotdog_stand.gd")
const FxScript := preload("res://scripts/fx.gd")
const LevelArtScript := preload("res://scripts/level_art.gd")
const HazardArtScript := preload("res://scripts/hazard_art.gd")
const BackgroundScript := preload("res://scripts/background.gd")
const RainScript := preload("res://scripts/rain.gd")
const HudScript := preload("res://scripts/hud.gd")
const TouchScript := preload("res://scripts/touch_controls.gd")

# Sobrevivem ao recarregamento da cena.
static var current_level := 0
static var score := 0
static var level_start_score := 0

var level: GDScript
var grid := PackedStringArray()
var cols := 0
var rows := 0
var world: Node2D
var player
var hud
## Chefe da fase, se houver (ele mesmo se registra aqui).
var boss

var _finished := false
var _next_action := ""


func _ready() -> void:
	_setup_input()
	level_start_score = score
	level = LEVELS[current_level % LEVELS.size()]
	_parse_map(level.MAP)

	var bg = BackgroundScript.new()
	bg.main = self
	add_child(bg)
	world = Node2D.new()
	add_child(world)

	var art = LevelArtScript.new()
	art.main = self
	world.add_child(art)
	var hazards = HazardArtScript.new()
	hazards.main = self
	world.add_child(hazards)

	_build_collision()
	_spawn_entities()

	add_child(RainScript.new())
	hud = HudScript.new()
	hud.main = self
	add_child(hud)
	add_child(TouchScript.new())
	hud.show_banner(level.NAME, level.SUBTITLE)
	Audio.music(level_const("MUSIC", "fase1"))


func _physics_process(_delta: float) -> void:
	if player == null or player.dead or _finished:
		return
	if HAZARD.contains(char_at_world(player.global_position + Vector2(0, -3))):
		player.hurt(1)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_music"):
		hud.show_message("Música ligada" if Audio.toggle_music() else "Música desligada")
	if not _finished or hud.overlay_time() < 0.8:
		return
	for action in ["restart", "jump", "shoot"]:
		if Input.is_action_just_pressed(action):
			_continue()
			return


func _input(event: InputEvent) -> void:
	if _finished and hud.overlay_time() >= 0.8 and event is InputEventScreenTouch and event.pressed:
		_continue()


# --- Mapa -------------------------------------------------------------------

func _parse_map(lines: Array) -> void:
	for line in lines:
		grid.append(line)
		cols = maxi(cols, line.length())
	rows = grid.size()
	for i in rows:
		grid[i] = grid[i].rpad(cols)


func char_at(cx: int, cy: int) -> String:
	if cx < 0 or cy < 0 or cx >= cols or cy >= rows:
		return "#"
	return grid[cy][cx]


func char_at_world(pos: Vector2) -> String:
	return char_at(floori(pos.x / TILE), floori(pos.y / TILE))


func is_solid_cell(cx: int, cy: int) -> bool:
	return SOLID.contains(char_at(cx, cy))


## Verdadeiro se há chão (sólido ou plataforma) na posição.
func is_solid_at(pos: Vector2) -> bool:
	var c := char_at_world(pos)
	return SOLID.contains(c) or c == ONE_WAY


func is_ladder_at(pos: Vector2) -> bool:
	return char_at_world(pos) == LADDER


func is_one_way_below(pos: Vector2) -> bool:
	var c := char_at_world(pos + Vector2(0, 4))
	return c == ONE_WAY or c == LADDER


func snap_to_cell_center(x: float) -> float:
	return floorf(x / TILE) * TILE + TILE / 2.0


## Constante opcional do arquivo da fase (ex.: INTERIOR_BG), com valor padrão.
func level_const(name: String, default: Variant) -> Variant:
	return level.get_script_constant_map().get(name, default)


func level_pixel_size() -> Vector2i:
	return Vector2i(cols * TILE, rows * TILE)


# --- Construção -------------------------------------------------------------

func _build_collision() -> void:
	var solid := StaticBody2D.new()
	solid.collision_layer = 1
	world.add_child(solid)
	for r in _merge_rects(_row_runs(SOLID)):
		_add_rect(solid, Rect2(r.position * TILE, r.size * TILE), false)

	# Plataformas atravessáveis por baixo ficam na camada 5 (valor 16), para
	# o jogador poder descer por elas.
	var one_way := StaticBody2D.new()
	one_way.collision_layer = 16
	world.add_child(one_way)
	for r in _row_runs(ONE_WAY):
		_add_rect(one_way, Rect2(r.position * TILE, Vector2(r.size.x * TILE, 6)), true)
	# O topo de cada escada também funciona como plataforma.
	for y in rows:
		for x in cols:
			if char_at(x, y) == LADDER and (y == 0 or char_at(x, y - 1) != LADDER):
				_add_rect(one_way, Rect2(x * TILE, y * TILE, TILE, 6), true)


## Sequências horizontais de células cujo caractere está em `chars`.
func _row_runs(chars: String) -> Array[Rect2i]:
	var runs: Array[Rect2i] = []
	for y in rows:
		var start := -1
		for x in cols + 1:
			var inside := x < cols and chars.contains(grid[y][x])
			if inside and start < 0:
				start = x
			elif not inside and start >= 0:
				runs.append(Rect2i(start, y, x - start, 1))
				start = -1
	return runs


## Junta sequências de mesma largura em linhas consecutivas num só retângulo.
func _merge_rects(runs: Array[Rect2i]) -> Array[Rect2i]:
	var by_row := {}
	for r in runs:
		if not by_row.has(r.position.y):
			by_row[r.position.y] = []
		by_row[r.position.y].append(r)
	var result: Array[Rect2i] = []
	var open := {}
	for y in rows:
		var next := {}
		for r in by_row.get(y, []):
			var key := Vector2i(r.position.x, r.size.x)
			if open.has(key):
				var grown: Rect2i = open[key]
				grown.size.y += 1
				next[key] = grown
				open.erase(key)
			else:
				next[key] = r
		result.append_array(open.values())
		open = next
	result.append_array(open.values())
	return result


func _add_rect(body: StaticBody2D, r: Rect2, one_way: bool) -> void:
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = r.size
	cs.shape = shape
	cs.position = r.position + r.size / 2.0
	cs.one_way_collision = one_way
	body.add_child(cs)


func _spawn_entities() -> void:
	for y in rows:
		for x in cols:
			var c := grid[y][x]
			var feet := Vector2(x * TILE + TILE / 2.0, (y + 1) * TILE)
			var center := Vector2(x * TILE + TILE / 2.0, y * TILE + TILE / 2.0)
			match c:
				"P":
					player = PlayerScript.new()
					player.main = self
					player.position = feet
					player.died.connect(_on_player_died)
				"A":
					_spawn(GuardScript, feet)
				"D":
					_spawn(DroneScript, center)
				"C":
					_spawn(SnakeScript, feet)
				"B":
					_spawn(HotdogScript, feet)
				"J":
					_spawn(BossScript, feet)
				"X":
					_spawn(ClockBossScript, center)
				"m":
					if char_at(x - 1, y) != "m":
						var plat = PlatformScript.new()
						plat.main = self
						plat.position = Vector2(x * TILE, y * TILE)
						var w := 0
						while char_at(x + w, y) == "m":
							w += 1
						plat.width_cells = w
						world.add_child(plat)
				"K", "U", "+", "W", "*", "E":
					var p = PickupScript.new()
					p.kind = c
					p.main = self
					p.position = center
					world.add_child(p)
				"|", "!":
					if char_at(x, y - 1) != c:
						var door = DoorScript.new()
						door.main = self
						door.card = "red" if c == "|" else "blue"
						door.position = Vector2(x * TILE + TILE / 2.0, y * TILE)
						var h := 0
						while char_at(x, y + h) == c:
							h += 1
						door.height_cells = h
						world.add_child(door)
	assert(player != null, "O mapa precisa de um 'P' (início do jogador).")
	world.add_child(player)


func _spawn(script: GDScript, pos: Vector2) -> void:
	var e = script.new()
	e.main = self
	e.position = pos
	world.add_child(e)


# --- Jogo -------------------------------------------------------------------

func level_number() -> int:
	return current_level + 1


func boss_alive() -> bool:
	return is_instance_valid(boss) and boss.hp > 0


func get_score() -> int:
	return score


func add_score(points: int) -> void:
	score += points


func spawn_fx(pos: Vector2, color: Color, size: float) -> void:
	var fx = FxScript.new()
	fx.position = pos
	fx.color = color
	fx.size = size
	world.add_child(fx)


func level_complete() -> void:
	if _finished:
		return
	_finished = true
	player.frozen = true
	Audio.stop_music()
	Audio.sfx("level_complete")
	if current_level + 1 < LEVELS.size():
		_next_action = "next"
		hud.show_overlay("FASE CONCLUÍDA!", "Toque ou aperte ENTER\npara continuar")
	else:
		_next_action = "end"
		hud.show_overlay("FIM DA DEMO!", "Fase 4 – Morro do Querosene – em construção.\n\nToque ou aperte ENTER\npara jogar de novo")


func on_boss_defeated() -> void:
	Audio.music(level_const("MUSIC", "fase1"))


func _on_player_died() -> void:
	Audio.stop_music()
	Audio.sfx("death")
	_finished = true
	_next_action = "retry"
	hud.show_overlay("SISTEMA DESLIGADO", "Toque ou aperte ENTER\npara tentar de novo")


func _continue() -> void:
	match _next_action:
		"retry":
			score = level_start_score
		"next":
			current_level += 1
		"end":
			current_level = 0
			score = 0
	get_tree().reload_current_scene.call_deferred()


func _setup_input() -> void:
	var keys := {
		"move_left": [KEY_LEFT, KEY_A],
		"move_right": [KEY_RIGHT, KEY_D],
		"move_up": [KEY_UP, KEY_W],
		"move_down": [KEY_DOWN, KEY_S],
		"jump": [KEY_SPACE, KEY_Z, KEY_K],
		"shoot": [KEY_X, KEY_J, KEY_CTRL],
		"restart": [KEY_ENTER, KEY_R],
		"toggle_music": [KEY_M],
	}
	var pad := {
		"move_left": JOY_BUTTON_DPAD_LEFT,
		"move_right": JOY_BUTTON_DPAD_RIGHT,
		"move_up": JOY_BUTTON_DPAD_UP,
		"move_down": JOY_BUTTON_DPAD_DOWN,
		"jump": JOY_BUTTON_A,
		"shoot": JOY_BUTTON_X,
		"restart": JOY_BUTTON_START,
		"toggle_music": JOY_BUTTON_BACK,
	}
	for action in keys:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for key in keys[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)
		var joy := InputEventJoypadButton.new()
		joy.button_index = pad[action]
		InputMap.action_add_event(action, joy)

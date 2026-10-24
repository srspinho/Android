extends CharacterBody2D
## Duca Neon: ex-segurança do metrô com braço cibernético e um blaster.
## A origem do nó fica nos pés do personagem.

signal died

const BulletScript := preload("res://scripts/bullet.gd")

const SPEED := 120.0
const ACCEL := 1000.0
const FRICTION := 1400.0
const GRAVITY := 980.0
const JUMP_VELOCITY := -330.0
const MAX_FALL := 420.0
const CLIMB_SPEED := 80.0
const COYOTE_TIME := 0.1
const JUMP_BUFFER_TIME := 0.12
## Camadas: 1 = cenário sólido, 16 = plataformas atravessáveis.
const MASK_NORMAL := 1 | 16
const MASK_PASS := 1

const C_JACKET := Color("#1b1035")
const C_PINK := Color("#ff2bd6")
const C_VISOR := Color("#00f0ff")
const C_SKIN := Color("#c98b5e")
const C_HAIR := Color("#7a2cff")
const C_PANTS := Color("#2a2a48")
const C_BOOTS := Color("#0d0d14")
const C_METAL := Color("#9aa4b8")
const C_GUN := Color("#4a5068")

var main
var max_hp := 8
var hp := 8
var facing := 1
var has_keycard := false
var rapid_fire := 0.0
var frozen := false
var dead := false

var _shoot_cd := 0.0
var _invuln := 0.0
var _coyote := 0.0
var _jump_buffer := 0.0
var _drop_timer := 0.0
var _climbing := false
var _anim := 0.0
var _muzzle := 0.0


func _ready() -> void:
	collision_layer = 2
	collision_mask = MASK_NORMAL
	floor_snap_length = 4.0
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(10, 22)
	cs.shape = rect
	cs.position = Vector2(0, -11)
	add_child(cs)

	var size: Vector2i = main.level_pixel_size()
	var cam := Camera2D.new()
	cam.position = Vector2(0, -24)
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = size.x
	cam.limit_bottom = size.y
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0
	add_child(cam)
	cam.reset_smoothing.call_deferred()


func _physics_process(delta: float) -> void:
	_anim += delta
	_shoot_cd -= delta
	_invuln -= delta
	_muzzle -= delta
	_drop_timer -= delta
	rapid_fire = maxf(rapid_fire - delta, 0.0)
	if dead:
		return
	if frozen:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
		move_and_slide()
		queue_redraw()
		return

	var dir := Input.get_axis("move_left", "move_right")
	var vdir := Input.get_axis("move_up", "move_down")
	if dir != 0.0:
		facing = 1 if dir > 0.0 else -1

	var ladder_here: bool = main.is_ladder_at(global_position + Vector2(0, -8))
	var ladder_below: bool = main.is_ladder_at(global_position + Vector2(0, 4))
	if not _climbing:
		if (ladder_here and vdir < -0.5) or (ladder_below and vdir > 0.5 and is_on_floor()):
			_climbing = true
			global_position.x = main.snap_to_cell_center(global_position.x)
			velocity = Vector2.ZERO

	if _climbing:
		_process_climb(dir, vdir, ladder_here, ladder_below)
	else:
		_process_move(delta, dir, vdir)

	collision_mask = MASK_PASS if (_climbing or _drop_timer > 0.0) else MASK_NORMAL
	move_and_slide()

	if Input.is_action_pressed("shoot") and _shoot_cd <= 0.0 and not _climbing:
		_shoot()
	queue_redraw()


func _process_climb(dir: float, vdir: float, ladder_here: bool, ladder_below: bool) -> void:
	velocity = Vector2(0.0, vdir * CLIMB_SPEED)
	if Input.is_action_just_pressed("jump"):
		_climbing = false
		velocity = Vector2(dir * SPEED, JUMP_VELOCITY * 0.7)
	elif not ladder_here and not ladder_below:
		_climbing = false
	elif not ladder_here and vdir < 0.0:
		# Chegou ao topo: um pulinho para subir na plataforma.
		_climbing = false
		velocity.y = -150.0
	elif dir != 0.0 and vdir == 0.0 and is_on_floor():
		_climbing = false


func _process_move(delta: float, dir: float, vdir: float) -> void:
	if is_on_floor():
		_coyote = COYOTE_TIME
	else:
		_coyote -= delta
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)

	if Input.is_action_just_pressed("jump"):
		_jump_buffer = JUMP_BUFFER_TIME
	else:
		_jump_buffer -= delta

	if _jump_buffer > 0.0 and _coyote > 0.0:
		_jump_buffer = 0.0
		_coyote = 0.0
		if vdir > 0.5 and main.is_one_way_below(global_position):
			_drop_timer = 0.25  # baixo + pulo: desce da plataforma
		else:
			velocity.y = JUMP_VELOCITY

	# Soltar o botão de pulo cedo faz um pulo mais baixo.
	if velocity.y < 0.0 and not Input.is_action_pressed("jump"):
		velocity.y = maxf(velocity.y, JUMP_VELOCITY * 0.4)

	var rate := ACCEL if dir != 0.0 else FRICTION
	if not is_on_floor():
		rate *= 0.7
	velocity.x = move_toward(velocity.x, dir * SPEED, rate * delta)


func _shoot() -> void:
	_shoot_cd = 0.11 if rapid_fire > 0.0 else 0.3
	_muzzle = 0.06
	var b = BulletScript.new()
	b.main = main
	b.from_player = true
	b.direction = Vector2(facing, 0)
	b.position = global_position + Vector2(facing * 13, -15)
	main.world.add_child(b)


func hurt(amount: int) -> void:
	if _invuln > 0.0 or dead or frozen:
		return
	hp = maxi(hp - amount, 0)
	_invuln = 1.2
	_climbing = false
	velocity = Vector2(-facing * 100.0, -160.0)
	main.spawn_fx(global_position + Vector2(0, -12), C_PINK, 10.0)
	if hp == 0:
		dead = true
		main.spawn_fx(global_position + Vector2(0, -12), C_VISOR, 24.0)
		visible = false
		died.emit()


func heal(amount: int) -> void:
	hp = mini(hp + amount, max_hp)


# --- Desenho ----------------------------------------------------------------

## Retângulo espelhado conforme o lado para onde o herói olha.
func _r(x: float, y: float, w: float, h: float, c: Color) -> void:
	if facing < 0:
		x = -x - w
	draw_rect(Rect2(x, y, w, h), c)


func _draw() -> void:
	if _invuln > 0.0 and int(_invuln * 20.0) % 2 == 0:
		return
	var step := 0.0
	if _climbing:
		step = sin(global_position.y * 0.3) * 2.0
	elif is_on_floor() and absf(velocity.x) > 10.0:
		step = sin(_anim * 16.0) * 2.0
	elif not is_on_floor():
		step = 2.0

	# Pernas e botas
	_r(-4 + step, -9, 3, 7, C_PANTS)
	_r(1 - step, -9, 3, 7, C_PANTS)
	_r(-5 + step, -2, 4, 2, C_BOOTS)
	_r(1 - step, -2, 4, 2, C_BOOTS)
	# Jaqueta com detalhes em neon
	_r(-5, -19, 10, 10, C_JACKET)
	_r(-5, -19, 1, 10, C_PINK)
	_r(-5, -10, 10, 1, C_PINK)
	_r(0, -17, 1, 6, Color(C_VISOR, 0.6))
	# Cabeça, moicano e visor
	_r(-3, -25, 7, 6, C_SKIN)
	_r(-4, -27, 6, 3, C_HAIR)
	_r(-2, -30, 3, 3, C_PINK)
	_r(1, -24, 4, 2, C_VISOR)
	# Brilho do visor
	_r(4, -25, 3, 4, Color(C_VISOR, 0.25))

	if _climbing:
		_r(-6, -26 + step, 3, 9, C_METAL)
		_r(4, -26 - step, 3, 9, C_SKIN)
		return
	# Braço cibernético e blaster
	_r(1, -17, 7, 3, C_METAL)
	_r(6, -18, 7, 4, C_GUN)
	_r(11, -17, 2, 1, C_VISOR)
	if _muzzle > 0.0:
		var tip := Vector2(15 * facing, -16)
		draw_circle(tip, 4.0, Color(C_VISOR, 0.5))
		draw_circle(tip, 2.0, Color.WHITE)

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

const HERO := preload("res://art/hero.png")
const HudScript := preload("res://scripts/hud.gd")
# Quadros de art/hero.png
const F_STAND := 0
const F_RUN := [1, 2, 1, 3]
const F_JUMP := 4
const F_CLIMB := [5, 6]
## Os quadros 7 a 11 repetem parado/corrida/pulo mirando para cima.
const F_AIM_UP_OFFSET := 7
## Mirando para cima, a câmera sobe para mostrar o que está lá em cima.
const LOOK_UP := 64.0
const LOOK_SPEED := 220.0

var main
var max_hp := 8
var hp := 8
var facing := 1
## Cartões de acesso coletados: "red", "blue".
var keycards := {}
var rapid_fire := 0.0
var frozen := false
var dead := false

var _shoot_cd := 0.0
var _invuln := 0.0
var _coyote := 0.0
var _jump_buffer := 0.0
## Ao descer de uma plataforma (baixo + pulo), o herói ignora as plataformas
## até os pés passarem desta altura (o corpo inteiro já abaixo dela).
var _drop_until_y := -INF
var _climbing := false
var _anim := 0.0
var _muzzle := 0.0
var _sprite: Sprite2D
var _aim_up := false
var _cam: Camera2D


func _ready() -> void:
	collision_layer = 2
	collision_mask = MASK_NORMAL
	floor_snap_length = 4.0
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(12, 28)
	cs.shape = rect
	cs.position = Vector2(0, -14)
	add_child(cs)

	_sprite = Sprite2D.new()
	_sprite.texture = HERO
	_sprite.hframes = 12
	_sprite.position = Vector2(0, -16)
	add_child(_sprite)

	var size: Vector2i = main.level_pixel_size()
	var cam := Camera2D.new()
	_cam = cam
	# O HUD cobre a direita e a parte de baixo da tela: a câmera compensa
	# para o herói ficar no meio da área de jogo.
	cam.position = Vector2(HudScript.PANEL_W / 2.0, -20 + HudScript.BAR_H / 2.0)
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = size.x + HudScript.PANEL_W
	cam.limit_bottom = size.y + HudScript.BAR_H
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0
	add_child(cam)
	cam.reset_smoothing.call_deferred()


func _physics_process(delta: float) -> void:
	_anim += delta
	_shoot_cd -= delta
	_invuln -= delta
	_muzzle -= delta
	rapid_fire = maxf(rapid_fire - delta, 0.0)
	if dead:
		return
	if frozen:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
		move_and_slide()
		_animate()
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

	# Segurar para cima (fora da escada) mira o blaster para o alto.
	_aim_up = vdir < -0.5 and not _climbing
	_cam.offset.y = move_toward(_cam.offset.y, -LOOK_UP if _aim_up else 0.0, LOOK_SPEED * delta)
	var dropping := global_position.y < _drop_until_y
	collision_mask = MASK_PASS if (_climbing or dropping) else MASK_NORMAL
	move_and_slide()

	if Input.is_action_pressed("shoot") and _shoot_cd <= 0.0 and not _climbing:
		_shoot()
	_animate()


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
			# baixo + pulo: desce da plataforma (6 px de espessura + altura do corpo)
			_drop_until_y = global_position.y + 6.0 + 28.0 + 2.0
		else:
			velocity.y = JUMP_VELOCITY
			Audio.sfx("jump")

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
	Audio.sfx("shoot")
	var b = BulletScript.new()
	b.main = main
	b.from_player = true
	if _aim_up:
		b.direction = Vector2.UP
		# Nasce dentro da largura do corpo: encostado numa parede, o tiro
		# não pode começar dentro dela.
		b.position = global_position + Vector2(facing * 4, -30)
	else:
		b.direction = Vector2(facing, 0)
		b.position = global_position + Vector2(facing * 12, -17)
	main.world.add_child(b)


func hurt(amount: int) -> void:
	if _invuln > 0.0 or dead or frozen:
		return
	hp = maxi(hp - amount, 0)
	_invuln = 1.2
	_climbing = false
	velocity = Vector2(-facing * 100.0, -160.0)
	main.spawn_fx(global_position + Vector2(0, -14), Color("#ff2bd6"), 10.0)
	Audio.sfx("hurt")
	if hp == 0:
		dead = true
		main.spawn_fx(global_position + Vector2(0, -14), Color("#54fcfc"), 24.0)
		visible = false
		died.emit()


func heal(amount: int) -> void:
	hp = mini(hp + amount, max_hp)


# --- Desenho ----------------------------------------------------------------

func _animate() -> void:
	_sprite.visible = not (_invuln > 0.0 and int(_invuln * 20.0) % 2 == 0)
	_sprite.flip_h = facing < 0
	if _climbing:
		_sprite.frame = F_CLIMB[int(global_position.y / 8.0) % 2]
		queue_redraw()
		return
	var f := F_STAND
	if not is_on_floor():
		f = F_JUMP
	elif absf(velocity.x) > 10.0:
		f = F_RUN[int(_anim * 10.0) % F_RUN.size()]
	_sprite.frame = f + (F_AIM_UP_OFFSET if _aim_up else 0)
	queue_redraw()


func _draw() -> void:
	# Clarão do tiro na ponta do blaster
	if _muzzle > 0.0 and _sprite.visible:
		var tip := Vector2(facing * 8, -33) if _aim_up else Vector2(facing * 13, -17)
		draw_rect(Rect2(tip - Vector2(3, 3), Vector2(6, 6)), Color("#54fcfc"))
		draw_rect(Rect2(tip - Vector2(1, 1), Vector2(3, 3)), Color.WHITE)

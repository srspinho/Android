## Teste rápido da fase 2: tiro para cima no drone do serpentário, descer no
## fosso e sair pela escada, pegar o cartão azul, abrir a porta azul, derrotar
## a JARARACA-X e sair. Imprime cada etapa e salva prints.
## Uso: godot --path . res://tests/smoke_test_fase2.tscn -- <pasta_para_prints>
extends Node

const MainScript := preload("res://scripts/main.gd")

var main
var shots_dir := ""


func _ready():
	shots_dir = OS.get_cmdline_user_args()[0]
	MainScript.current_level = 1
	main = load("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	_run.call_deferred()


func wait(sec: float):
	await get_tree().create_timer(sec).timeout


func shot(name: String):
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(shots_dir + "/" + name + ".png")


func hold(action: String, sec: float):
	Input.action_press(action)
	await wait(sec)
	Input.action_release(action)


func cell(x: int, row_below: int) -> Vector2:
	return Vector2(x * 16 + 8, row_below * 16)


func _run():
	await wait(0.6)
	var p = main.player
	print("FASE: ", main.level_number(), " ", main.level.NAME)
	await shot("f2_01_parque")

	# Drone sobre o serpentário
	p.global_position = cell(24, 13); await wait(0.5)
	var score0: int = main.get_score()
	Input.action_press("move_up"); Input.action_press("shoot")
	await wait(0.3); await shot("f2_02_tiro_cima")
	await wait(1.7)
	Input.action_release("shoot"); Input.action_release("move_up")
	print("DRONE: pontos ", score0, " -> ", main.get_score(), " (esperado +150)")

	# Descer no fosso (baixo + pulo) e sair pela escada
	p.global_position = cell(22, 13); p.velocity = Vector2.ZERO; await wait(0.3)
	while not p.is_on_floor():  # um tiro perdido do drone pode ter empurrado o herói
		await get_tree().physics_frame
	Input.action_press("move_down"); await hold("jump", 0.1); Input.action_release("move_down")
	await wait(0.8)
	print("FOSSO: y=", p.global_position.y, " (esperado 272)")
	await shot("f2_03_fosso")
	p.global_position = cell(30, 17); p.velocity = Vector2.ZERO; await wait(0.3)
	await hold("move_up", 1.6)
	print("SAIU DO FOSSO: y=", p.global_position.y, " (esperado 208)")

	# Laboratório: andar de cima e cartão azul
	p.global_position = cell(60, 8); await wait(0.6)
	await shot("f2_04_lab")
	p.global_position = cell(96, 8); await wait(0.3)
	print("CARTAO AZUL: ", p.keycards.get("blue", false))

	# Porta azul
	p.global_position = cell(97, 13); await wait(0.3)
	await hold("move_right", 0.8)
	print("PORTA AZUL: x=", p.global_position.x, " (passou se > 1610)")

	# Chefe
	p.global_position = cell(104, 13); p.hp = p.max_hp; await wait(0.3)
	print("CHEFE VIVO: ", main.boss_alive(), " vida ", main.boss.hp)
	p.global_position = cell(136, 13); await wait(0.3)
	print("SAIDA TRAVADA: overlay=", main.hud.overlay_time(), " (esperado -1)")
	p.global_position = cell(104, 13); p.velocity = Vector2.ZERO; await wait(0.2)
	var t := 0.0
	var took_rear_shot := false
	Input.action_press("move_right"); await wait(0.05); Input.action_release("move_right")
	Input.action_press("shoot")
	while main.boss_alive() and t < 30.0:
		p.hp = p.max_hp  # o teste não quer morrer, só bater
		if not took_rear_shot and main.boss.sprite.frame == 2:
			took_rear_shot = true
			await shot("f2_06_chefe_cospe")
		if t > 1.0 and t < 1.1:
			await shot("f2_05_chefe")
		await get_tree().physics_frame
		t += 1.0 / 60.0
	Input.action_release("shoot")
	print("CHEFE DERROTADO: ", not main.boss_alive(), " em ", snappedf(t, 0.1), " s, pontos ", main.get_score())
	await wait(0.3); await shot("f2_07_chefe_derrotado")
	p.global_position = cell(136, 13); await wait(1.0)
	await shot("f2_08_fim")
	print("FIM: overlay=", main.hud.overlay_time())
	get_tree().quit()

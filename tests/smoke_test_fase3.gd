## Teste rápido da fase 3: subir a escada da biblioteca e pegar o cartão,
## pegar carona numa plataforma móvel da Raia, levar dano na água, abrir a
## porta vermelha, derrubar o CRONOS-X com tiro para cima e sair.
## Uso: godot --path . res://tests/smoke_test_fase3.tscn -- <pasta_para_prints>
extends Node

const MainScript := preload("res://scripts/main.gd")

var main
var shots_dir := ""


func _ready():
	shots_dir = OS.get_cmdline_user_args()[0]
	MainScript.current_level = 2
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


func _platforms() -> Array:
	return main.world.get_children().filter(func(n): return n is AnimatableBody2D)


func _run():
	await wait(0.6)
	var p = main.player
	print("FASE: ", main.level_number(), " ", main.level.NAME)
	await shot("f3_01_portao")

	# Biblioteca: escada até o terraço e cartão vermelho
	p.global_position = cell(29, 15); p.velocity = Vector2.ZERO; await wait(0.3)
	await hold("move_up", 2.2)
	print("TERRACO: y=", p.global_position.y, " (esperado 128)")
	p.hp = p.max_hp
	Input.action_press("shoot")  # o androide do terraço está no caminho
	await hold("move_right", 2.0)
	Input.action_release("shoot")
	print("CARTAO VERMELHO: ", p.keycards.get("red", false))
	await shot("f3_02_biblioteca")

	# Raia: carona na plataforma móvel
	var plats := _platforms()
	print("PLATAFORMAS: ", plats.size(), " (esperado 3)")
	var plat = plats[0]
	p.hp = p.max_hp
	p.global_position = plat.position + Vector2(24, -2); p.velocity = Vector2.ZERO
	await wait(0.3)
	var px0: float = p.global_position.x
	var plat_x0: float = plat.position.x
	await wait(1.5)
	print("CARONA: plataforma andou ", snappedf(plat.position.x - plat_x0, 0.1), ", herói andou ", snappedf(p.global_position.x - px0, 0.1), ", y=", p.global_position.y, " (esperado ", plat.position.y, ")")
	await shot("f3_03_raia")

	# Água machuca
	p.hp = p.max_hp
	p.global_position = cell(60, 16); p.velocity = Vector2.ZERO
	await wait(0.3)
	print("AGUA: energia ", p.max_hp, " -> ", p.hp, " (deve cair)")
	await wait(1.3)

	# Porta vermelha
	p.hp = p.max_hp
	p.global_position = cell(110, 15); p.velocity = Vector2.ZERO; await wait(0.3)
	await hold("move_right", 0.8)
	print("PORTA VERMELHA: x=", p.global_position.x, " (passou se > 1800)")

	# CRONOS-X: só o tiro para cima alcança
	p.global_position = cell(124, 15); await wait(0.5)
	print("CHEFE: ", main.boss.display_name, " vivo=", main.boss_alive(), " vida=", main.boss.hp)
	p.global_position = cell(147, 15); await wait(0.3)
	print("SAIDA TRAVADA: overlay=", main.hud.overlay_time(), " (esperado -1)")
	p.global_position = cell(124, 15); await wait(0.2)
	Input.action_press("move_up"); Input.action_press("shoot")
	var t := 0.0
	var shots_taken := 0
	while main.boss_alive() and t < 40.0:
		p.hp = p.max_hp
		p.global_position.x = main.boss.global_position.x  # fica embaixo dele
		if shots_taken == 0 and t > 1.0:
			shots_taken = 1
			await shot("f3_04_cronos")
		if shots_taken == 1 and main.boss.hp < main.boss.max_hp / 2 and main.boss.sprite.frame == 2:
			shots_taken = 2
			await shot("f3_05_cronos_furioso")
		await get_tree().physics_frame
		t += 1.0 / 60.0
	Input.action_release("shoot"); Input.action_release("move_up")
	print("CHEFE DERROTADO: ", not main.boss_alive(), " em ", snappedf(t, 0.1), " s, pontos ", main.get_score())
	p.hp = p.max_hp
	p.global_position = cell(147, 15); await wait(1.0)
	await shot("f3_06_fim")
	print("FIM: overlay=", main.hud.overlay_time())
	get_tree().quit()

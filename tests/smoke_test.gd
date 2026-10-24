## Teste rápido: joga a fase 1 sozinho (anda, atira para cima no drone, usa a
## barraquinha de dogão, desce a escada, pega o cartão, abre a porta, chega na saída), imprime o resultado e salva prints.
## Uso: godot --path . res://tests/smoke_test.tscn -- <pasta_para_prints>
extends Node

var main
var shots_dir := ""

func _ready():
	shots_dir = OS.get_cmdline_user_args()[0]
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

func _count_drones() -> int:
	var n := 0
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.get_script().resource_path.ends_with("enemy_drone.gd"):
			n += 1
	return n

func _run():
	await wait(0.6)
	var p = main.player
	await shot("01_inicio")
	var x0: float = p.global_position.x
	await hold("move_right", 0.5)
	print("ANDAR: ", x0, " -> ", p.global_position.x)
	Input.action_press("jump"); await wait(0.15)
	print("PULO y: ", p.global_position.y); Input.action_release("jump")
	await wait(0.6)
	Input.action_press("shoot"); await wait(0.05); await shot("02_tiro"); Input.action_release("shoot")
	# prédio / drone: tiro para cima
	p.global_position = Vector2(41*16+8, 8*16); await wait(0.8); await shot("03_predio")
	var drones_before := _count_drones()
	var score_before: int = main.get_score()
	p.hp = 8
	Input.action_press("move_up"); Input.action_press("shoot")
	await wait(0.25); await shot("03b_tiro_cima")
	await wait(1.5)
	Input.action_release("shoot"); Input.action_release("move_up")
	print("TIRO PARA CIMA: drones ", drones_before, " -> ", _count_drones(), " pontos ", score_before, " -> ", main.get_score())
	# barraquinha de dogão
	p.hp = 3
	p.global_position = Vector2(48*16, 13*16); await wait(0.2)
	await hold("move_right", 0.3)
	await wait(0.2); await shot("03c_dogao")
	print("DOGAO: energia 3 -> ", p.hp, " (esperado 8)")
	# escada do metrô
	p.global_position = Vector2(63*16+8, 13*16); p.velocity = Vector2.ZERO; await wait(0.3)
	print("NO TOPO DA ESCADA y=", p.global_position.y, " chao=", p.is_on_floor())
	await hold("move_down", 2.5)
	print("DESCEU ESCADA y=", p.global_position.y, " (esperado ~352)")
	await shot("04_metro")
	await hold("move_up", 0.6)
	print("SUBINDO y=", p.global_position.y)
	await hold("move_down", 1.0)
	# porta sem cartão
	p.global_position = Vector2(97*16, 22*16); await wait(0.2)
	await hold("move_right", 1.0)
	print("PORTA SEM CARTAO x=", p.global_position.x, " (deve parar antes de 1600)")
	await shot("05_porta")
	p.global_position = Vector2(4*16, 22*16); await wait(0.3)
	print("CARTAO: ", p.has_keycard)
	p.global_position = Vector2(97*16, 22*16); await wait(0.2)
	await hold("move_right", 1.2)
	print("PORTA COM CARTAO x=", p.global_position.x)
	# escada de saída
	p.global_position = Vector2(110*16+8, 22*16); p.velocity = Vector2.ZERO; await wait(0.3)
	await hold("move_up", 2.6)
	print("SUBIU ESCADA 2 y=", p.global_position.y, " chao=", p.is_on_floor(), " (esperado 208)")
	await shot("06_rua2")
	p.hp = 8
	p.global_position = Vector2(123*16, 13*16); await wait(0.2)
	await hold("move_right", 0.5)
	await wait(0.6)
	await shot("07_fim")
	print("FIM overlay=", main.hud.overlay_time(), " score=", main.get_score(), " hp=", p.hp)
	get_tree().quit()

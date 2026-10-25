extends "res://scripts/enemy_base.gd"
## Base dos chefes: vida grande com barra no HUD, acorda quando o jogador
## chega perto ou atira nele (e não volta a dormir), música própria e a saída
## da fase travada enquanto estiver vivo (ver main.boss_alive()).

var max_hp := 30
var display_name := "CHEFE"
var defeat_message := "CHEFE DESTRUÍDO! A saída está liberada"

var _awake := false


func _ready() -> void:
	super._ready()
	hp = max_hp
	main.boss = self


## Chamar no começo do _ai() de cada chefe.
func wake_up() -> void:
	if _awake:
		return
	_awake = true
	active_range = 4000.0  # nada de derrotar o chefe de longe enquanto dorme
	Audio.music("boss")
	Audio.sfx("boss_roar")


func hurt(amount: int) -> void:
	wake_up()
	super.hurt(amount)
	if hp <= 0:
		for i in 6:
			main.spawn_fx(global_position + Vector2(randf_range(-30, 30), randf_range(-30, 0)), body_color, 24.0)
		main.hud.show_message(defeat_message)
		main.on_boss_defeated()

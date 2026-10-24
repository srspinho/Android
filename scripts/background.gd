extends ParallaxBackground
## Fundo da cidade em camadas de pixel art: céu com lua neon, silhuetas com a
## Torre do Relógio da USP e, mais perto, a camada própria de cada fase
## (constante BACKDROP_NEAR no arquivo da fase).

const MIRROR := 512.0

var main


func _ready() -> void:
	_layer(preload("res://art/bg_sky.png"), Vector2.ZERO)
	_layer(preload("res://art/bg_far.png"), Vector2(0.1, 0.0))
	_layer(load(main.level_const("BACKDROP_NEAR", "res://art/bg_near.png")), Vector2(0.3, 0.0))


func _layer(tex: Texture2D, motion: Vector2) -> void:
	var pl := ParallaxLayer.new()
	pl.motion_scale = motion
	pl.motion_mirroring = Vector2(MIRROR, 0)
	add_child(pl)
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	pl.add_child(s)

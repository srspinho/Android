extends ParallaxBackground
## Fundo da cidade em camadas de pixel art: céu com lua neon, silhuetas com a
## Torre do Relógio da USP e, mais perto, prédios e o outdoor da Serpentis.

const MIRROR := 512.0


func _ready() -> void:
	_layer(preload("res://art/bg_sky.png"), Vector2.ZERO)
	_layer(preload("res://art/bg_far.png"), Vector2(0.1, 0.0))
	_layer(preload("res://art/bg_near.png"), Vector2(0.3, 0.0))


func _layer(tex: Texture2D, motion: Vector2) -> void:
	var pl := ParallaxLayer.new()
	pl.motion_scale = motion
	pl.motion_mirroring = Vector2(MIRROR, 0)
	add_child(pl)
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	pl.add_child(s)

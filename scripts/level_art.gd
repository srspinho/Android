extends Node2D
## Desenha as partes paradas do mapa com os tiles de art/tiles.png
## (blocos, plataformas, escadas, postes, letreiros e a parede de fundo
## das áreas cobertas). É desenhado uma vez só.

const PixelFont := preload("res://scripts/pixel_font.gd")
const TILES := preload("res://art/tiles.png")
const LAMP := preload("res://art/lamp.png")
const PLANT := preload("res://art/plant.png")

const T := 16
# Índices dos tiles em art/tiles.png (mesma ordem de TILE_NAMES no gerador).
const FLOOR_TOP := 0
const PANEL := 1
const CRATE := 2
const VENT := 3
const CEILING := 4
const GIRDER := 5
const CATWALK := 6
const LADDER := 7
const PILLAR := 14
const DEEP := 15
const METRO := 16

var main

var _interior: Texture2D


func _ready() -> void:
	# Cada fase pode ter sua parede de fundo (constante INTERIOR_BG).
	_interior = load(main.level_const("INTERIOR_BG", "res://art/bg_tech.png"))


func _draw() -> void:
	_draw_interiors()
	for y in main.rows:
		for x in main.cols:
			var pos := Vector2(x * T, y * T)
			match main.char_at(x, y):
				"#":
					_tile(_block_tile(x, y), pos)
				"=":
					_tile(GIRDER, pos)
				"-":
					_tile(CATWALK, pos)
				"H":
					_tile(LADDER, pos)
				"M":
					_tile(METRO, pos)
				"L":
					draw_texture(LAMP, pos + Vector2(0, T - LAMP.get_height()))
				"v":
					draw_texture(PLANT, pos + Vector2((T - PLANT.get_width()) / 2.0, T - PLANT.get_height()))
	for s in main.level.SIGNS:
		_sign(s)


func _tile(index: int, pos: Vector2) -> void:
	draw_texture_rect_region(TILES, Rect2(pos, Vector2(T, T)), Rect2(index * T, 0, T, T))


## Escolhe o desenho do bloco conforme os vizinhos: chão com faixa zebrada
## em cima, teto com canos embaixo, pilar nas laterais e caixas/painéis dentro.
func _block_tile(x: int, y: int) -> int:
	if not main.is_solid_cell(x, y - 1):
		return FLOOR_TOP
	if not main.is_solid_cell(x, y + 1):
		return CEILING
	if not main.is_solid_cell(x - 1, y) or not main.is_solid_cell(x + 1, y):
		return PILLAR
	match (x * 7 + y * 13) % 9:
		0:
			return VENT
		1, 2:
			return CRATE
		3:
			return DEEP
	return PANEL


## Áreas cobertas (como o subsolo do metrô) ganham parede industrial ao
## fundo em vez de mostrar o céu da cidade.
func _draw_interiors() -> void:
	var w := _interior.get_width()
	var h := _interior.get_height()
	for x in main.cols:
		var covered := false
		for y in main.rows:
			if main.char_at(x, y) == "#":
				covered = true
				continue
			var walled: bool = main.is_solid_cell(x - 1, y) and main.is_solid_cell(x + 1, y)
			if covered or walled:
				var src := Rect2(posmod(x * T, w), posmod(y * T, h), T, T)
				draw_texture_rect_region(_interior, Rect2(x * T, y * T, T, T), src)


## Letreiro de neon: {"pos": Vector2i(célula), "text": "...", "color": "rrggbb"}
func _sign(s: Dictionary) -> void:
	var color := Color(s.get("color", "ff2bd6"))
	var pos := Vector2(s["pos"]) * T + Vector2(4, 4)
	var box := Rect2(pos - Vector2(4, 4), Vector2(PixelFont.width(s["text"]) + 9, 15))
	draw_rect(box, Color("#07040f"))
	draw_rect(box.grow(-1), Color(color, 0.5), false, 1.0)
	draw_rect(box, Color.BLACK, false, 1.0)
	PixelFont.draw(self, pos, s["text"], color)

extends RefCounted
## Fase 3 – Cidade Universitária (USP).
##
## Mesma legenda das fases anteriores (veja levels/fase1_estacao_butanta.gd), mais:
##   w  água contaminada da Raia (machuca, como o lodo)
##   m  plataforma móvel (mmm = 3 blocos); vai e volta entre as marcas ":"
##   :  marca invisível onde a plataforma móvel faz a volta
##   X  CRONOS-X (chefe voador: só o tiro para cima alcança)

const NAME := "CIDADE UNIVERSITÁRIA"
const SUBTITLE := "Os drones da Serpentis tomaram a USP.\nAtravesse a Raia e suba até\na Praça do Relógio!"

const INTERIOR_BG := "res://art/bg_tech.png"
const BACKDROP_NEAR := "res://art/bg_usp.png"
## Música da fase (arquivo em audio/music, gerado por tools/gen_audio.py).
const MUSIC := "fase3"

const SIGNS := [
	{"pos": Vector2i(1, 3), "text": "CIDADE UNIVERSITÁRIA", "color": "fcfc54"},
	{"pos": Vector2i(8, 6), "text": "PORTÃO 1", "color": "54fcfc"},
	{"pos": Vector2i(31, 9), "text": "BIBLIOTECA", "color": "fc54fc"},
	{"pos": Vector2i(54, 9), "text": "RAIA OLÍMPICA", "color": "54fcfc"},
	{"pos": Vector2i(85, 10), "text": "BANDEJÃO", "color": "fcfc54"},
	{"pos": Vector2i(114, 3), "text": "PRAÇA DO RELÓGIO", "color": "fc5454"},
]

const MAP := [
	"#                                                                                                                                                    #",
	"#                                                                                                                                                    #",
	"#                                                                                                                                                    #",
	"#                                D                                                                                                                   #",
	"#                                                                                                                                                    #",
	"#                                                                                                      D                                             #",
	"#               D                                                          D                                    #                                    #",
	"#                                 A  K                    D                                                     #                X                   #",
	"#        * * *               H#########                                                                         #                                    #",
	"#      =========             H#########                                                                         #                                    #",
	"#                            H#########                                  W                         **           #     +                     W        #",
	"#                            H                              *                                     ----          |   ----       -----       ----      #",
	"#   --                       H                                     :  mmm        :                              |                                    #",
	"#                            H             :mmm    :##:mmm      :##                                             |                                    #",
	"#  P  L         L v   A v L  H  +       v           ##           ##                 L   B    v   A   v    A L   |                                  E #",
	"##########################################wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww###################################################################",
	"######################################################################################################################################################",
	"######################################################################################################################################################",
	"######################################################################################################################################################",
	"######################################################################################################################################################",
	"######################################################################################################################################################",
	"######################################################################################################################################################",
]

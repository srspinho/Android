extends RefCounted
## Fase 2 – Instituto Butantan.
##
## Mesma legenda da fase 1 (veja levels/fase1_estacao_butanta.gd), mais:
##   U  cartão azul           !  porta de laser azul
##   v  planta tropical       J  JARARACA-X (chefe: a saída só abre depois dela)

const NAME := "INSTITUTO BUTANTAN"
const SUBTITLE := "A Serpentis transformou o serpentário\nnuma fábrica de cobras-robô.\nAche a JARARACA-X e desligue tudo!"

## Parede de fundo das áreas cobertas e camada próxima do fundo da cidade.
const INTERIOR_BG := "res://art/bg_lab.png"
const BACKDROP_NEAR := "res://art/bg_butantan.png"

const SIGNS := [
	{"pos": Vector2i(2, 5), "text": "INSTITUTO BUTANTAN", "color": "54fc54"},
	{"pos": Vector2i(20, 9), "text": "SERPENTÁRIO", "color": "fcfc54"},
	{"pos": Vector2i(45, 4), "text": "LABORATÓRIO SERPENTIS", "color": "fc54fc"},
	{"pos": Vector2i(77, 9), "text": "REFEITÓRIO", "color": "fcfc54"},
	{"pos": Vector2i(52, 10), "text": "VENENO", "color": "54fc54"},
	{"pos": Vector2i(103, 4), "text": "SALA DA JARARACA-X", "color": "fc5454"},
]

const MAP := [
	"#                                                                                                                                          #",
	"#                                                                                                                                          #",
	"#                                         ##################################################################################################",
	"#                                         ##                                                        #                                      #",
	"#                                         ##                *     D                   *             #                                      #",
	"#                       D                 ##              -----                     ----            #                                      #",
	"#                                         ##                                                        #                                      #",
	"#                                         ##        +                 C           A             U   #                                      #",
	"#                                         ######H#########################   #############H##########       +                              #",
	"#                                         ##    H                                         H         #     -----                 -----      #",
	"#                                               H                                         H         !                                      #",
	"#                                               H                                         H         !                                      #",
	"#  P   v  L   v C                 v A  v        H             A     C           B         H   A     !                     J             E  #",
	"##################------------H########################~~~##################################################################################",
	"##################            H#############################################################################################################",
	"##################            H#############################################################################################################",
	"################## * C  W C * H#############################################################################################################",
	"############################################################################################################################################",
	"############################################################################################################################################",
	"############################################################################################################################################",
]

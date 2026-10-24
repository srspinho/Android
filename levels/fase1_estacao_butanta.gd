extends RefCounted
## Fase 1 – Estação Butantã (Linha 4 Amarela).
##
## O mapa é desenhado com caracteres; cada um ocupa uma célula de 16x16 px.
##   #  bloco sólido          =  plataforma de metal (sólida)
##   -  plataforma atravessável (dá para pular por baixo; baixo + pulo desce)
##   H  escada                ~  lodo tóxico          ^  trilho energizado
##   P  início do jogador     E  saída da fase        |  porta de laser (cartão)
##   A  androide segurança    D  drone                C  cobra cibernética
##   K  cartão vermelho       +  coxinha (energia)    W  turbo no blaster
##   *  chip de dados         L  poste de luz         M  logo do metrô
##   B  barraquinha de dogão (enche a energia; ocupa 3 blocos de largura)
## Pulo máximo: 3 blocos de altura e uns 4 de distância.

const NAME := "ESTAÇÃO BUTANTÃ"
const SUBTITLE := "Av. Vital Brasil, 2087.\nA Serpentis Biotech fechou a rua.\nDesça pelo metrô!"

const SIGNS := [
	{"pos": Vector2i(2, 5), "text": "AV. VITAL BRASIL", "color": "00f0ff", "size": 11},
	{"pos": Vector2i(38, 9), "text": "MORRO DO QUEROSENE", "color": "ff2bd6", "size": 9},
	{"pos": Vector2i(54, 8), "text": "ESTAÇÃO BUTANTÃ", "color": "ffd000", "size": 12},
	{"pos": Vector2i(64, 5), "text": "BLOQUEIO CORPORATIVO", "color": "ff3355", "size": 9},
	{"pos": Vector2i(1, 16), "text": "DEPÓSITO DA MANUTENÇÃO", "color": "b388ff", "size": 9},
	{"pos": Vector2i(40, 17), "text": "CUIDADO: TRILHO ENERGIZADO", "color": "ffe66b", "size": 9},
	{"pos": Vector2i(66, 16), "text": "LINHA 4 · AMARELA", "color": "ffd000", "size": 11},
	{"pos": Vector2i(94, 16), "text": "PLATAFORMA", "color": "ff3355", "size": 9},
	{"pos": Vector2i(110, 7), "text": "INSTITUTO BUTANTAN →", "color": "39ff14", "size": 11},
]

const MAP := [
	"#                                                                                                                              #",
	"#                                                                                                                              #",
	"#                                                                           ##                                                 #",
	"#                                                                           ##                                                 #",
	"#                                        D                                  ##                                                 #",
	"#                                                                           ##                                                 #",
	"#                                                                           ##                        D                        #",
	"#                                          +                                ##                                                 #",
	"#              * *                   #########                              ##        *                                        #",
	"#             =====                  #########                              ##      =====                                      #",
	"#                               ---  #########                              ##                                                 #",
	"#        ###                         #########                        *     ##                                                 #",
	"#  P  L  ###        L   A            #########  L B   A      M        L C   ##            L     A                B     A  L E  #",
	"###########################~~~~################################H##############################################H#################",
	"###############################################################H##############################################H#################",
	"#                                                              H                                    |         H                #",
	"#                                                              H                                    |         H                #",
	"#                                                              H                D                   |         H                #",
	"#                      * W *                                   H                     *              |         H                #",
	"#                     -------                                  H                    ----            |         H                #",
	"#                                                              H                                    |         H                #",
	"#  K          C                     C                    B     H                          A         |   C     H                #",
	"############################################^^^#################################################################################",
	"################################################################################################################################",
]

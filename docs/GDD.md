# Neon Butantã: documento de design

## Conceito

Plataforma e tiro 2D com rolagem lateral, no espírito de **Duke Nukem** (1991): fases
tipo labirinto, cartões coloridos que abrem portas, itens escondidos, muitos inimigos
e um chefe no fim de cada região. Tudo acontece numa versão **cyberpunk do Butantã e
do Rio Pequeno em 2087**.

## História

Em 2087 a **Serpentis Biotech**, uma megacorporação de biotecnologia, comprou metade
da Zona Oeste. Ela fecha ruas com "bloqueios corporativos", vigia os bairros com drones
e faz experiências com cobras cibernéticas em laboratórios clandestinos, alguns perto
do Instituto Butantan.

**Duca Neon** era segurança do metrô até perder o braço num "acidente" da Serpentis.
Agora tem um braço cibernético, um blaster e o mapa de cada beco do bairro na cabeça.
Ele vai atravessar a região até a torre da Serpentis e desligar tudo.

## Estilo visual

Inspirado no **Duke Nukem II** (1993), com tema cyberpunk:

- Pixel art em 384×216, ampliada sem borrar, com paleta no espírito da EGA/VGA:
  cinzas metálicos, amarelo e preto das faixas de perigo, e os neons rosa `#fc54fc`,
  ciano `#54fcfc` e verde tóxico `#54fc54`
- Blocos de metal com chanfro, rebites, caixas com X, grades de ventilação e pilares;
  a parte de cima de cada chão tem faixa zebrada
- Personagens com contorno preto e sombreado de 2 a 3 tons
- Áreas internas com parede industrial de painéis cinza e azuis, como nas bases do
  Duke Nukem II; áreas externas com a cidade em parallax, chuva e letreiros de neon
- HUD com moldura de canos: painel lateral (ITENS, retrato, RADAR, FASE) e barra
  inferior (PONTOS, ARMA, ENERGIA)
- Pontos reais do bairro como referência, todos "futurizados"

## Mapa da campanha

| # | Fase | Inspiração real | Ideia |
|---|---|---|---|
| 1 | **Estação Butantã** ✅ demo | Av. Vital Brasil, estação da Linha 4 | Rua bloqueada, descer pelo metrô, cartão vermelho, porta da plataforma |
| 2 | **Instituto Butantan** | Instituto Butantan e o serpentário | Biolab invadido: cobras cibernéticas, tubos de veneno, chefe: **Jararaca-X** |
| 3 | **Cidade Universitária** | USP, Praça do Relógio, Raia Olímpica | Campus ocupado por drones, saltos sobre a Raia alagada, chefe na Torre do Relógio |
| 4 | **Morro do Querosene** | Bairro boêmio do Butantã | Becos verticais, telhados, festa de rua com hologramas, mercado negro de implantes |
| 5 | **Rio Pequeno** | Av. Escola Politécnica, córrego do Rio Pequeno | Favela vertical cyberpunk, elevadores improvisados, córrego tóxico |
| 6 | **Marginal Pinheiros** | Rio Pinheiros e as pontes | Fase de perseguição em cima de caminhões autônomos, rio radioativo |
| 7 | **Torre Serpentis** | Fictícia, onde hoje fica a skyline da Faria Lima ao fundo | Fase final vertical, chefe: CEO em exoesqueleto |

As fases podem ser destravadas num **mapa do bairro** entre elas, desenhado em estilo
de tela de computador antiga a partir do traçado real das ruas (OpenStreetMap).

## Personagem

- 8 pontos de energia, com 1,2 s de invencibilidade depois de levar dano
- Pulo variável (segurar = mais alto), "coyote time" e buffer de pulo, para o controle
  ficar justo no toque
- Sobe escadas e desce de plataformas finas (baixo + pulo)
- Blaster: tiro para a frente ou para cima (segurando ↑), e "turbo" temporário com o item W

**Ideias para depois:** botas de salto duplo, gancho para se pendurar (escalar prédios),
granada de pulso que derruba drones, escudo.

## Inimigos

| Inimigo | Comportamento | Vida | Pontos |
|---|---|---|---|
| Androide de segurança | Patrulha, para e atira quando vê o jogador na mesma altura | 3 | 200 |
| Drone de vigilância | Segue o jogador pelo ar e atira mirando nele; derrube com o tiro para cima | 2 | 150 |
| Cobra cibernética | Rasteja e dá o bote rápido quando o jogador chega perto | 2 | 150 |

**Planejados:** torreta de teto, motoqueiro com implantes (Marginal), aranha-robô de
manutenção do metrô, e os chefes de cada fase.

## Itens

| Símbolo no mapa | Item | Efeito |
|---|---|---|
| `+` | Coxinha energética | +2 de energia |
| `K` | Cartão vermelho | Abre portas de laser (`\|`) |
| `W` | Turbo no blaster | Tiro rápido por 15 s |
| `*` | Chip de dados | +250 créditos |
| `B` | Barraquinha de dogão | Enche a energia; depois fecha por 30 s. Fica em pontos estratégicos, antes dos trechos difíceis |

**Planejados:** cartões azul/verde/amarelo, pastel de feira (cura total), caldo de cana
turbinado (velocidade), segredos com bônus como no Duke Nukem.

## Controles no celular

- Direcional virtual à esquerda e **TIRO**/**PULO** à direita, com multitoque
- Tela sempre em paisagem e modo imersivo (sem barras do Android)
- Também funciona com controle Bluetooth

## Próximos passos

1. Jogar a demo no celular e ajustar a velocidade, o pulo e o tamanho dos botões
2. Efeitos sonoros e trilha synthwave
3. Fase 2 (Instituto Butantan) e o primeiro chefe
4. Tela de título, pausa e salvamento do progresso
5. Mapa do bairro entre as fases
6. Mais quadros de animação (tiro, dano, morte) e explosões em pixel art

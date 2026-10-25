#!/usr/bin/env python3
"""Gera toda a pixel art do jogo (estilo Duke Nukem II) na pasta art/.

Uso:  python3 tools/gen_art.py      (precisa do Pillow: pip install pillow)

Os sprites são desenhados com letras (cada letra é uma cor da paleta) e
ganham contorno preto automaticamente. Para mudar um desenho, edite as
letras aqui e rode o script de novo, ou edite os PNGs direto no Aseprite.
"""
import math
import os
import random

from PIL import Image

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art")

# Paleta inspirada na EGA/VGA dos jogos de 1993, com os neons do cyberpunk.
PAL = {
    "k": (0, 0, 0),
    "w": (252, 252, 252),
    "l": (196, 196, 196),
    "g": (140, 140, 140),
    "d": (84, 84, 84),
    "D": (44, 44, 44),
    "s": (252, 176, 108),
    "S": (196, 108, 48),
    "H": (252, 84, 252),
    "h": (168, 0, 168),
    "c": (84, 252, 252),
    "C": (0, 168, 168),
    "j": (60, 36, 112),
    "J": (100, 64, 170),
    "b": (40, 80, 200),
    "B": (24, 44, 128),
    "y": (252, 252, 84),
    "Y": (200, 160, 0),
    "r": (252, 84, 84),
    "R": (168, 0, 0),
    "o": (252, 156, 48),
    "O": (176, 88, 16),
    "e": (84, 252, 84),
    "E": (0, 168, 0),
    "f": (0, 88, 0),
}


def rgba(c, a=255):
    if isinstance(c, str):
        c = PAL[c]
    return (c[0], c[1], c[2], a)


def new(w, h):
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def ascii_sprite(rows, outline=True):
    """Converte linhas de letras em imagem (com 1 px de contorno preto)."""
    w = max(len(r) for r in rows)
    m = 1 if outline else 0
    img = new(w + 2 * m, len(rows) + 2 * m)
    px = img.load()
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch in PAL:
                px[x + m, y + m] = rgba(ch)
    if outline:
        add_outline(img)
    return img


def add_outline(img):
    w, h = img.size
    px = img.load()
    solid = [[px[x, y][3] > 0 for y in range(h)] for x in range(w)]
    for x in range(w):
        for y in range(h):
            if solid[x][y]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and solid[nx][ny]:
                    px[x, y] = rgba("k")
                    break


def rect(img, x, y, w, h, c):
    px = img.load()
    for yy in range(max(0, y), min(img.size[1], y + h)):
        for xx in range(max(0, x), min(img.size[0], x + w)):
            px[xx, yy] = rgba(c) if not (isinstance(c, tuple) and len(c) == 4) else c


def bevel(img, x, y, w, h, light, mid, dark):
    rect(img, x, y, w, h, mid)
    rect(img, x, y, w, 1, light)
    rect(img, x, y, 1, h, light)
    rect(img, x, y + h - 1, w, 1, dark)
    rect(img, x + w - 1, y, 1, h, dark)


def rivet(img, x, y):
    rect(img, x, y, 1, 1, "w")
    rect(img, x + 1, y + 1, 1, 1, "D")


def hazard(img, x, y, w, h):
    for yy in range(h):
        for xx in range(w):
            c = "y" if ((xx + yy) // 3) % 2 == 0 else "k"
            rect(img, x + xx, y + yy, 1, 1, c)


BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


def dither_pick(x, y, t, a, b):
    """Escolhe entre as cores a e b conforme t (0..1), com dithering ordenado."""
    return b if t * 16 > BAYER[y % 4][x % 4] + 0.5 else a


# --- Fonte pixelada 5x7 (com acentos) ------------------------------------------

GLYPHS = {
    "A": [".###.", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
    "B": ["####.", "#...#", "#...#", "####.", "#...#", "#...#", "####."],
    "C": [".###.", "#...#", "#....", "#....", "#....", "#...#", ".###."],
    "D": ["####.", "#...#", "#...#", "#...#", "#...#", "#...#", "####."],
    "E": ["#####", "#....", "#....", "####.", "#....", "#....", "#####"],
    "F": ["#####", "#....", "#....", "####.", "#....", "#....", "#...."],
    "G": [".###.", "#...#", "#....", "#.###", "#...#", "#...#", ".####"],
    "H": ["#...#", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
    "I": [".###.", "..#..", "..#..", "..#..", "..#..", "..#..", ".###."],
    "J": ["..###", "...#.", "...#.", "...#.", "...#.", "#..#.", ".##.."],
    "K": ["#...#", "#..#.", "#.#..", "##...", "#.#..", "#..#.", "#...#"],
    "L": ["#....", "#....", "#....", "#....", "#....", "#....", "#####"],
    "M": ["#...#", "##.##", "#.#.#", "#.#.#", "#...#", "#...#", "#...#"],
    "N": ["#...#", "#...#", "##..#", "#.#.#", "#..##", "#...#", "#...#"],
    "O": [".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
    "P": ["####.", "#...#", "#...#", "####.", "#....", "#....", "#...."],
    "Q": [".###.", "#...#", "#...#", "#...#", "#.#.#", "#..#.", ".##.#"],
    "R": ["####.", "#...#", "#...#", "####.", "#.#..", "#..#.", "#...#"],
    "S": [".####", "#....", "#....", ".###.", "....#", "....#", "####."],
    "T": ["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."],
    "U": ["#...#", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
    "V": ["#...#", "#...#", "#...#", "#...#", "#...#", ".#.#.", "..#.."],
    "W": ["#...#", "#...#", "#...#", "#.#.#", "#.#.#", "#.#.#", ".#.#."],
    "X": ["#...#", "#...#", ".#.#.", "..#..", ".#.#.", "#...#", "#...#"],
    "Y": ["#...#", "#...#", ".#.#.", "..#..", "..#..", "..#..", "..#.."],
    "Z": ["#####", "....#", "...#.", "..#..", ".#...", "#....", "#####"],
    "0": [".###.", "#...#", "#..##", "#.#.#", "##..#", "#...#", ".###."],
    "1": ["..#..", ".##..", "..#..", "..#..", "..#..", "..#..", ".###."],
    "2": [".###.", "#...#", "....#", "...#.", "..#..", ".#...", "#####"],
    "3": ["####.", "....#", "....#", ".###.", "....#", "....#", "####."],
    "4": ["...#.", "..##.", ".#.#.", "#..#.", "#####", "...#.", "...#."],
    "5": ["#####", "#....", "####.", "....#", "....#", "#...#", ".###."],
    "6": [".###.", "#....", "#....", "####.", "#...#", "#...#", ".###."],
    "7": ["#####", "....#", "...#.", "..#..", ".#...", ".#...", ".#..."],
    "8": [".###.", "#...#", "#...#", ".###.", "#...#", "#...#", ".###."],
    "9": [".###.", "#...#", "#...#", ".####", "....#", "....#", ".###."],
    " ": ["....."] * 7,
    "!": ["..#..", "..#..", "..#..", "..#..", "..#..", ".....", "..#.."],
    "?": [".###.", "#...#", "....#", "...#.", "..#..", ".....", "..#.."],
    ".": [".....", ".....", ".....", ".....", ".....", ".....", "..#.."],
    ",": [".....", ".....", ".....", ".....", ".....", "..#..", ".#..."],
    ":": [".....", "..#..", ".....", ".....", ".....", "..#..", "....."],
    ";": [".....", "..#..", ".....", ".....", ".....", "..#..", ".#..."],
    "-": [".....", ".....", ".....", ".###.", ".....", ".....", "....."],
    "–": [".....", ".....", ".....", "#####", ".....", ".....", "....."],
    "+": [".....", "..#..", "..#..", "#####", "..#..", "..#..", "....."],
    "/": ["....#", "...#.", "...#.", "..#..", ".#...", ".#...", "#...."],
    "(": ["...#.", "..#..", ".#...", ".#...", ".#...", "..#..", "...#."],
    ")": [".#...", "..#..", "...#.", "...#.", "...#.", "..#..", ".#..."],
    "%": ["##..#", "##..#", "...#.", "..#..", ".#...", "#..##", "#..##"],
    "'": ["..#..", "..#..", ".....", ".....", ".....", ".....", "....."],
    '"': [".#.#.", ".#.#.", ".....", ".....", ".....", ".....", "....."],
    "*": [".....", "#.#.#", ".###.", "#####", ".###.", "#.#.#", "....."],
    "·": [".....", ".....", ".....", "..#..", ".....", ".....", "....."],
    "→": [".....", "..#..", "...#.", "#####", "...#.", "..#..", "....."],
    "←": [".....", "..#..", ".#...", "#####", ".#...", "..#..", "....."],
    "x": [".....", ".....", "#...#", ".#.#.", "..#..", ".#.#.", "#...#"],
}
ACCENTS = {
    "´": ["...#.", "..#.."],
    "`": [".#...", "..#.."],
    "^": ["..#..", ".#.#."],
    "~": [".##.#", "#.##."],
}
ACCENTED = {
    "Á": ("A", "´"), "À": ("A", "`"), "Â": ("A", "^"), "Ã": ("A", "~"),
    "É": ("E", "´"), "Ê": ("E", "^"), "Í": ("I", "´"),
    "Ó": ("O", "´"), "Ô": ("O", "^"), "Õ": ("O", "~"), "Ú": ("U", "´"),
}
FONT_CHARS = "".join(GLYPHS.keys()) + "".join(ACCENTED.keys()) + "Ç"
CELL_W, CELL_H = 6, 10  # 2 linhas para acento em cima, 7 da letra, 1 para cedilha


def glyph_rows(ch):
    """Devolve 10 linhas de 5 colunas para o caractere."""
    rows = ["....."] * CELL_H
    if ch in ACCENTED:
        base, acc = ACCENTED[ch]
        rows[0:2] = ACCENTS[acc]
        rows[2:9] = GLYPHS[base]
    elif ch == "Ç":
        rows[2:9] = GLYPHS["C"]
        rows[9] = "..#.."
    else:
        rows[2:9] = GLYPHS.get(ch, GLYPHS["?"])
    return rows


def gen_font():
    img = new(CELL_W * len(FONT_CHARS), CELL_H)
    px = img.load()
    for i, ch in enumerate(FONT_CHARS):
        for y, row in enumerate(glyph_rows(ch)):
            for x, v in enumerate(row):
                if v == "#":
                    px[i * CELL_W + x, y] = (255, 255, 255, 255)
    img.save(os.path.join(ROOT, "font.png"))
    # A mesma ordem precisa estar em scripts/pixel_font.gd (const CHARS).
    print("Caracteres da fonte:", FONT_CHARS)


def text(img, x, y, s, color, shadow=None):
    """Escreve texto com a fonte pixelada direto numa imagem."""
    px = img.load()
    for i, ch in enumerate(s.upper()):
        for gy, row in enumerate(glyph_rows(ch)):
            for gx, v in enumerate(row):
                if v != "#":
                    continue
                X, Y = x + i * CELL_W + gx, y + gy - 2
                if shadow and 0 <= X + 1 < img.size[0] and 0 <= Y + 1 < img.size[1]:
                    px[X + 1, Y + 1] = rgba(shadow)
                if 0 <= X < img.size[0] and 0 <= Y < img.size[1]:
                    px[X, Y] = rgba(color)


# --- Herói: Duca Neon ---------------------------------------------------------------

HERO_UPPER = [
    "........Hh..........",
    ".......HHhh.........",
    "......hHHhhh........",
    "......Sssssss.......",
    "......Sssssssss.....",
    "......SsssDcccc.....",
    "......Ssssscccc.....",
    "......SSsssssss.....",
    ".......SSssssS......",
    "........SSSS........",
    ".....jjjjJJjjj......",
    "....jjjjJJcJjjj.....",
    "...jjjjjJJcJlllggddd",
    "...jjjjjJJcJggggDDDc",
    "...jHjjjJJcJjjj.D...",
    "...jHjjjJJcJjjj.....",
    "....jjjjJJJJjj......",
    "....DDDDyDDDDD......",
]
HERO_BACK = [
    "........Hh..........",
    ".......HHhh.........",
    "......hHHhhh........",
    "......hhhhhhh.......",
    "...ss.hhhhhhh.ss....",
    "...SS.hhhhhhh.SS....",
    "...jj.hhhhhhh.jj....",
    "...jj..hhhhh..jj....",
    "...jj...SSS...jj....",
    "...jjjjjjjjjjjjj....",
    "....jjjjjjjjjjj.....",
    "....jjjjHHHjjjj.....",
    "....jjjjHjHjjjj.....",
    "....jjjjHHHjjjj.....",
    "....jjjjjjjjjjj.....",
    "....jjjjjjjjjjj.....",
    "....jjjjjjjjjjj.....",
    "....DDDDyyDDDDD.....",
]
LEGS = {
    "stand": [
        "....bbbbbBbbbb......",
        "....bbbbbBbbbb......",
        "....bbbb..bbbb......",
        "....bbbB..bbbB......",
        "....bbbB..bbbB......",
        "....bbbB..bbbB......",
        "....bbbB..bbbB......",
        "....bbbB..bbbB......",
        "....gggg..gggg......",
        "...ggggg..ggggg.....",
        "...ddddd..ddddd.....",
    ],
    "runA": [
        "....bbbbbBbbbb......",
        "....bbbbb.bbbbb.....",
        "...bbbbb...bbbbb....",
        "...bbbB.....bbbB....",
        "..bbbB.......bbB....",
        "..bbB........bbbB...",
        ".bbB..........bbB...",
        ".bbB..........bbB...",
        "gggg..........gggg..",
        "ggggg.........ggggg.",
        "ddddd.........ddddd.",
    ],
    "runB": [
        "....bbbbbBbbbb......",
        "....bbbbbBbbbbb.....",
        ".....bbbB.bbbbb.....",
        ".....bbbB..bbbbb....",
        ".....bbbB...bbbB....",
        ".....bbbB...ggggg...",
        ".....bbbB...ddddd...",
        ".....bbbB...........",
        "....gggggg..........",
        "....gggggg..........",
        "....dddddd..........",
    ],
    "runC": [
        "....bbbbbBbbbb......",
        "....bbbbbBbbbbb.....",
        "....bbbbb.bbbbbb....",
        "...bbbbB....bbbbB...",
        "...bbbB......bbbbb..",
        "...bbbB.......ggggg.",
        "...bbbB.......ddddd.",
        "...bbbB.............",
        "..gggggg............",
        "..gggggg............",
        "..dddddd............",
    ],
    "jump": [
        "....bbbbbBbbbb......",
        "...bbbbbbbbbbbb.....",
        "..bbbbB...bbbbbb....",
        "..bbbB.....bbbbB....",
        "..gggggg....gggggg..",
        "..dddddd....dddddd..",
        "....................",
        "....................",
        "....................",
        "....................",
        "....................",
    ],
    "climb2": [
        "....bbbbbBbbbb......",
        "....bbbb..bbbb......",
        "....bbbB..bbbB......",
        "....bbbB..gggg......",
        "....bbbB..dddd......",
        "....bbbB............",
        "....bbbB............",
        "....bbbB............",
        "....gggg............",
        "...ggggg............",
        "...ddddd............",
    ],
}
# Mirando para cima: braço erguido e blaster apontado para o alto.
HERO_UP = [
    "........Hh.....cc...",
    ".......HHhh....DD...",
    "......hHHhhh...dD...",
    "......Sssssss..dD...",
    "......Sssssssssdd...",
    "......SsssDccccgg...",
    "......Ssssscccclg...",
    "......SSssssssslg...",
    ".......SSssssSlg....",
    "........SSSSllg.....",
    ".....jjjjJJlgj......",
    "....jjjjJJcgjjj.....",
    "...jjjjjJJcJjjj.....",
    "...jjjjjJJcJjjj.....",
    "...jHjjjJJcJjjj.....",
    "...jHjjjJJcJjjj.....",
    "....jjjjJJJJjj......",
    "....DDDDyDDDDD......",
]
# A ordem dos quadros precisa bater com as constantes F_* de scripts/player.gd.
HERO_FRAMES = [
    (HERO_UPPER, "stand"),
    (HERO_UPPER, "runA"),
    (HERO_UPPER, "runB"),
    (HERO_UPPER, "runC"),
    (HERO_UPPER, "jump"),
    (HERO_BACK, "stand"),
    (HERO_BACK, "climb2"),
    (HERO_UP, "stand"),
    (HERO_UP, "runA"),
    (HERO_UP, "runB"),
    (HERO_UP, "runC"),
    (HERO_UP, "jump"),
]


def sheet(frames, cell_w, cell_h, x_off, name):
    """Monta uma tira de quadros, com cada sprite apoiado no fundo da célula."""
    img = new(cell_w * len(frames), cell_h)
    for i, spr in enumerate(frames):
        img.alpha_composite(spr, (i * cell_w + x_off, cell_h - spr.size[1]))
    img.save(os.path.join(ROOT, name))


def gen_hero():
    frames = [ascii_sprite(upper + LEGS[legs]) for upper, legs in HERO_FRAMES]
    sheet(frames, 32, 32, 7, "hero.png")


# --- Inimigos ---------------------------------------------------------------------

GUARD_UPPER = [
    "........r...........",
    "........d...........",
    "......lllll.........",
    ".....lggggggl.......",
    ".....lgDyyyyyD......",
    ".....lgDyyyyyD......",
    ".....lggggggggd.....",
    "......dggggggd......",
    ".......dddddd.......",
    "...lllgggggggllll...",
    "..lgyyggggggggyygl..",
    "..lgdggggggggdgldddd",
    "..lgdgggrrgggdgDDDDr",
    "..lgdgggrrgggdg.d...",
    "..lgdggggggggdg.....",
    "...dgyyyyyyyyg......",
    "....gggggggggg......",
    "....dddddddddd......",
]
GUARD_LEGS = [
    [
        "....ggg....ggg......",
        "....lgd....lgd......",
        "....lgd....lgd......",
        "....ddd....ddd......",
        "....lgd....lgd......",
        "....lgd....lgd......",
        "....lgd....lgd......",
        "...llgdd..llgdd.....",
        "...ddddd..ddddd.....",
    ],
    [
        "....ggg....ggg......",
        "...lgd......lgd.....",
        "...lgd......lgd.....",
        "...ddd......ddd.....",
        "..lgd........lgd....",
        "..lgd........lgd....",
        "..lgd........lgd....",
        ".llgdd......llgdd...",
        ".ddddd......ddddd...",
    ],
]
DRONE = [
    [
        "lllll........lllll..",
        "...d..........d.....",
        "...dddllllllldd.....",
        "..dlggggggggggld....",
        ".dlggDDrrDDgggggld..",
        ".dlgDrrwrrDgggggld..",
        ".dlggDDrrDDgggggld..",
        "..dggggggggggggd....",
        "...dHHHHHHHHHHd.....",
        "....d..d..d..d......",
    ],
    [
        "..lllll....lllll....",
        "...d..........d.....",
        "...dddllllllldd.....",
        "..dlggggggggggld....",
        ".dlggDDrrDDgggggld..",
        ".dlgDrrwrrDgggggld..",
        ".dlggDDrrDDgggggld..",
        "..dggggggggggggd....",
        "...dhhhhhhhhhhd.....",
        "...d..d..d..d.......",
    ],
]


def snake_frame(phase):
    """Cobra cibernética: segmentos verdes com anéis de metal, cabeça à direita."""
    img = new(26, 12)
    for i in range(8):
        x = 2 + i * 2
        y = 5 + round(math.sin(phase + i * 0.9) * 1.5)
        c = "g" if i % 3 == 2 else ("e" if i % 2 == 0 else "E")
        rect(img, x, y, 3, 4, c)
        rect(img, x, y + 3, 3, 1, "f" if c != "g" else "d")
    hy = 3 + round(math.sin(phase + 8 * 0.9) * 1.0)
    rect(img, 18, hy, 6, 5, "E")
    rect(img, 18, hy, 6, 1, "e")
    rect(img, 21, hy + 1, 1, 1, "r")
    rect(img, 18, hy + 4, 6, 1, "f")
    rect(img, 24, hy + 3, 2, 1, "H")
    add_outline(img)
    return img


def gen_enemies():
    sheet([ascii_sprite(GUARD_UPPER + legs) for legs in GUARD_LEGS], 32, 32, 6, "guard.png")
    sheet([ascii_sprite(f) for f in DRONE], 32, 16, 5, "drone.png")
    sheet([snake_frame(0.0), snake_frame(1.6)], 32, 16, 3, "snake.png")


# --- Itens -----------------------------------------------------------------------

ITEMS = {
    "coxinha": [
        ".....oO.....",
        "....ooOO....",
        "....oooO....",
        "...oyooOO...",
        "...oyoooO...",
        "..oyooooOO..",
        "..ooooooOO..",
        ".ooooooooOO.",
        ".oooooooOOO.",
        "..OOOOOOOO..",
    ],
    "card": [
        "rrrrrrrrrrrr",
        "rDDDDDDDDDDr",
        "rrrrrrrrrrrr",
        "rYyrrrrrwwwr",
        "rYyrrrrrrrrr",
        "rrrrrrrrwwwr",
        "RRRRRRRRRRRR",
    ],
    "turbo": [
        "..llll..",
        ".DDDDDD.",
        ".DcccCD.",
        ".DccwCD.",
        ".DcwcCD.",
        ".DwwwwD.",
        ".DCcwCD.",
        ".DCwCCD.",
        ".DwCCCD.",
        ".DDDDDD.",
    ],
    "chip": [
        "..g.g.g..",
        ".DDDDDDD.",
        "gDEEEEEDg",
        ".DEeeeED.",
        "gDEeweEDg",
        ".DEeeeED.",
        "gDEEEEEDg",
        ".DDDDDDD.",
        "..g.g.g..",
    ],
    "card_blue": [
        "bbbbbbbbbbbb",
        "bDDDDDDDDDDb",
        "bbbbbbbbbbbb",
        "bYybbbbbwwwb",
        "bYybbbbbbbbb",
        "bbbbbbbbwwwb",
        "BBBBBBBBBBBB",
    ],
}
# A ordem precisa bater com FRAMES em scripts/pickup.gd e com o HUD.
ITEM_ORDER = ["coxinha", "card", "turbo", "chip", "card_blue"]


def gen_items():
    img = new(16 * len(ITEM_ORDER), 16)
    for i, name in enumerate(ITEM_ORDER):
        spr = ascii_sprite(ITEMS[name])
        img.alpha_composite(spr, (i * 16 + (16 - spr.size[0]) // 2, (16 - spr.size[1]) // 2))
    img.save(os.path.join(ROOT, "items.png"))

    # Porta de saída 32x48
    ex = new(32, 48)
    bevel(ex, 0, 8, 32, 40, "l", "g", "D")
    rect(ex, 4, 12, 24, 36, "k")
    for y in range(14, 48, 4):
        rect(ex, 6, y, 20, 1, "f")
    rect(ex, 14, 22, 4, 14, "E")
    rect(ex, 10, 30, 12, 2, "E")
    for i in range(4):
        rect(ex, 10 + i, 28 + i, 1, 1, "e")
    rect(ex, 1, 0, 30, 9, "k")
    rect(ex, 1, 0, 30, 1, "E")
    text(ex, 2, 2, "SAÍDA", "e")
    ex.save(os.path.join(ROOT, "exit.png"))


# --- Retrato do HUD ------------------------------------------------------------------

PORTRAIT = [
    "........HHH.........",
    ".......HHHHh........",
    "......hHHHHhh.......",
    ".....SssssssssS.....",
    "....SssssssssssS....",
    "....DDDDDDDDDDDD....",
    "....DccccCDccccC....",
    "....DcwccCDcwccC....",
    "....DDDDDDDDDDDD....",
    "....SssssssssssS....",
    "....SsssssSsssssS...",
    "....SssssssssssS....",
    ".....SssRRRRssS.....",
    ".....SSssssssSS.....",
    "......SSSssSSS......",
    ".......SSSSSS.......",
    "....jjjjSSSSjjjj....",
    "..jjjjjjjSSjjjjjjj..",
    ".jjjJjjjjccjjjjJjjj.",
    ".jjjJjjjjccjjjjJjjj.",
]


def gen_portrait():
    img = new(32, 32)
    for y in range(32):
        for x in range(32):
            c = "C" if (x % 6 == 0 or y % 6 == 0) else "k"
            rect(img, x, y, 1, 1, c if c == "k" else (0, 60, 70, 255))
    spr = ascii_sprite(PORTRAIT)
    img.alpha_composite(spr, ((32 - spr.size[0]) // 2, 32 - spr.size[1]))
    img.save(os.path.join(ROOT, "portrait.png"))


# --- Tiles 16x16 -------------------------------------------------------------------

TILE_NAMES = [
    "floor_top", "panel", "crate", "vent", "ceiling", "girder", "catwalk", "ladder",
    "sludge0", "sludge1", "sludge2", "sludge3", "rail0", "rail1", "pillar", "deep",
    "metro", "water0", "water1", "water2", "water3",
]


def tile_floor_top():
    t = new(16, 16)
    rect(t, 0, 0, 16, 16, "d")
    rect(t, 0, 0, 16, 1, "w")
    rect(t, 0, 1, 16, 3, "l")
    rect(t, 3, 2, 3, 1, "g")
    rect(t, 10, 2, 3, 1, "g")
    rect(t, 0, 4, 16, 1, "D")
    hazard(t, 0, 5, 16, 4)
    rect(t, 0, 9, 16, 1, "k")
    bevel(t, 0, 10, 16, 6, "g", "d", "D")
    rivet(t, 2, 12)
    rivet(t, 12, 12)
    return t


def tile_panel():
    t = new(16, 16)
    bevel(t, 0, 0, 16, 16, "l", "g", "D")
    bevel(t, 3, 3, 10, 10, "d", "g", "l")
    rivet(t, 1, 1)
    rivet(t, 13, 1)
    rivet(t, 1, 13)
    rivet(t, 13, 13)
    return t


def tile_crate():
    t = new(16, 16)
    bevel(t, 0, 0, 16, 16, "w", "l", "d")
    rect(t, 2, 2, 12, 12, "g")
    for i in range(12):
        rect(t, 2 + i, 2 + i, 1, 1, "D")
        rect(t, 13 - i, 2 + i, 1, 1, "D")
        if i < 11:
            rect(t, 3 + i, 2 + i, 1, 1, "l")
            rect(t, 12 - i, 2 + i, 1, 1, "l")
    rect(t, 1, 1, 14, 1, "d")
    rect(t, 1, 14, 14, 1, "w")
    return t


def tile_vent():
    t = new(16, 16)
    bevel(t, 0, 0, 16, 16, "l", "g", "D")
    for y in (3, 6, 9, 12):
        rect(t, 2, y, 12, 1, "k")
        rect(t, 2, y + 1, 12, 1, "d")
    return t


def tile_ceiling():
    t = new(16, 16)
    bevel(t, 0, 0, 16, 10, "g", "d", "D")
    rect(t, 0, 10, 16, 6, "D")
    rect(t, 0, 11, 16, 1, "c")
    rect(t, 0, 12, 16, 1, "l")
    rect(t, 0, 13, 16, 1, "g")
    rect(t, 0, 14, 16, 1, "d")
    rect(t, 6, 10, 3, 6, "d")
    rect(t, 6, 10, 1, 6, "g")
    return t


def tile_girder():
    t = new(16, 16)
    rect(t, 0, 0, 16, 1, "w")
    rect(t, 0, 1, 16, 2, "l")
    rect(t, 0, 3, 16, 1, "d")
    hazard(t, 0, 4, 16, 5)
    rect(t, 0, 9, 16, 1, "k")
    rect(t, 0, 10, 16, 6, "D")
    for i in range(6):
        rect(t, i, 10 + i, 1, 1, "g")
        rect(t, 15 - i, 10 + i, 1, 1, "g")
        rect(t, 8 + i // 2, 10 + i, 1, 1, "d")
    rect(t, 0, 15, 16, 1, "d")
    return t


def tile_catwalk():
    t = new(16, 16)
    rect(t, 0, 0, 16, 1, "w")
    rect(t, 0, 1, 16, 2, "g")
    for x in range(1, 16, 3):
        rect(t, x, 1, 1, 2, "D")
    rect(t, 0, 3, 16, 1, "d")
    rect(t, 2, 4, 2, 5, "d")
    rect(t, 12, 4, 2, 5, "d")
    rect(t, 2, 4, 1, 5, "g")
    rect(t, 12, 4, 1, 5, "g")
    return t


def tile_ladder():
    t = new(16, 16)
    for x in (2, 12):
        rect(t, x, 0, 1, 16, "l")
        rect(t, x + 1, 0, 1, 16, "d")
    for y in (1, 5, 9, 13):
        rect(t, 3, y, 9, 1, "l")
        rect(t, 3, y + 1, 9, 1, "D")
    return t


def tile_sludge(frame):
    t = new(16, 16)
    for x in range(16):
        top = 3 + round(math.sin((x + frame * 4) * 0.8) * 1.2)
        for y in range(top, 16):
            if y == top:
                c = "e"
            else:
                c = dither_pick(x + frame, y, (y - top) / 12, "E", "f")
            rect(t, x, y, 1, 1, c)
    random.seed(frame * 7 + 1)
    for _ in range(2):
        bx, by = random.randint(2, 13), random.randint(6, 13)
        rect(t, bx, by, 1, 1, "w")
        rect(t, bx + 1, by, 1, 1, "e")
    return t


def tile_rail(frame):
    t = new(16, 16)
    rect(t, 0, 10, 16, 6, "D")
    rect(t, 0, 10, 16, 1, "l")
    rect(t, 0, 11, 16, 1, "g")
    rect(t, 3, 12, 2, 4, "d")
    rect(t, 11, 12, 2, 4, "d")
    random.seed(frame * 13 + 5)
    y = 6
    for x in range(16):
        y = max(2, min(9, y + random.choice((-2, -1, 0, 1, 2))))
        rect(t, x, y, 1, 1, "w" if x % 4 == 0 else ("c" if frame == 0 else "y"))
    return t


def tile_pillar():
    t = new(16, 16)
    cols = ["D", "l", "w", "w", "l", "l", "g", "g", "l", "w", "l", "l", "g", "d", "d", "k"]
    for x, c in enumerate(cols):
        rect(t, x, 0, 1, 16, c)
    rect(t, 1, 7, 14, 1, "d")
    rect(t, 1, 8, 14, 1, "w")
    return t


def tile_water(frame):
    """Água (contaminada) da Raia Olímpica: azul com reflexos ciano."""
    t = new(16, 16)
    for x in range(16):
        top = 3 + round(math.sin((x + frame * 4) * 0.5) * 1.3)
        for y in range(top, 16):
            if y == top:
                c = "c"
            else:
                c = dither_pick(x + frame * 2, y, (y - top) / 13, "b", "B")
            rect(t, x, y, 1, 1, c)
    random.seed(frame * 3 + 11)
    for _ in range(3):
        rect(t, random.randint(1, 13), random.randint(7, 14), 2, 1, "c")
    return t


def tile_deep():
    t = new(16, 16)
    for y in range(16):
        for x in range(16):
            rect(t, x, y, 1, 1, dither_pick(x, y, 0.25, "D", "d"))
    return t


def tile_metro():
    t = new(16, 16)
    rect(t, 1, 1, 14, 14, "k")
    rect(t, 2, 2, 12, 12, "y")
    rect(t, 2, 13, 12, 1, "Y")
    rect(t, 13, 2, 1, 12, "Y")
    text(t, 5, 5, "4", "k")
    return t


def gen_tiles():
    tiles = [
        tile_floor_top(), tile_panel(), tile_crate(), tile_vent(), tile_ceiling(),
        tile_girder(), tile_catwalk(), tile_ladder(),
        tile_sludge(0), tile_sludge(1), tile_sludge(2), tile_sludge(3),
        tile_rail(0), tile_rail(1), tile_pillar(), tile_deep(), tile_metro(),
        tile_water(0), tile_water(1), tile_water(2), tile_water(3),
    ]
    img = new(16 * len(tiles), 16)
    for i, t in enumerate(tiles):
        img.alpha_composite(t, (i * 16, 0))
    img.save(os.path.join(ROOT, "tiles.png"))

    # Poste de luz 16x48
    lamp = new(16, 48)
    rect(lamp, 6, 4, 3, 44, "d")
    rect(lamp, 6, 4, 1, 44, "g")
    rect(lamp, 6, 2, 9, 3, "d")
    rect(lamp, 6, 2, 9, 1, "g")
    rect(lamp, 10, 5, 5, 2, "c")
    rect(lamp, 11, 5, 3, 1, "w")
    rect(lamp, 4, 44, 7, 4, "D")
    add_outline(lamp)
    lamp.save(os.path.join(ROOT, "lamp.png"))


# --- Fundos -------------------------------------------------------------------------

def gen_tech_backdrop():
    """Parede de painéis industriais para áreas internas (como no Duke Nukem II)."""
    W, H = 128, 128
    img = new(W, H)
    dl, dm, dd, dk = (98, 98, 112), (70, 70, 84), (44, 44, 56), (26, 26, 34)
    bl, bm = (36, 44, 140), (22, 26, 92)
    rect(img, 0, 0, W, H, (*dm, 255))

    def pb(x, y, w, h):
        bevel(img, x, y, w, h, dl, dm, dd)

    pb(0, 0, 64, 40)
    pb(0, 40, 32, 48)
    pb(32, 40, 32, 48)
    pb(0, 88, 64, 40)
    pb(64, 72, 64, 56)
    # Painel azul rebaixado
    for y in range(4, 68):
        for x in range(68, 124):
            rect(img, x, y, 1, 1, (*dither_pick(x, y, 0.35, bm, bl), 255))
    rect(img, 68, 4, 56, 1, (*dk, 255))
    rect(img, 68, 4, 1, 64, (*dk, 255))
    rect(img, 68, 67, 56, 1, (*dl, 255))
    rect(img, 123, 4, 1, 64, (*dl, 255))
    for i in range(20):
        rect(img, 80 + i, 20 + i, 2, 1, (*dm, 255))
    pb(84, 40, 24, 16)
    # Grade de ventilação
    for y in range(46, 84, 4):
        rect(img, 4, y, 24, 1, (*dk, 255))
        rect(img, 4, y + 1, 24, 1, (*dl, 255))
    # Janelinhas e detalhes
    for x in (8, 18):
        rect(img, x, 8, 6, 12, (*dk, 255))
        rect(img, x + 1, 9, 4, 10, (*dd, 255))
    for y in (12, 18, 24):
        rect(img, 30, y, 24, 2, (*dd, 255))
        rect(img, 30, y + 2, 24, 1, (*dl, 255))
    # Luz vermelha octogonal
    cx, cy = 96, 100
    for y in range(-9, 10):
        for x in range(-9, 10):
            if abs(x) + abs(y) <= 13 and abs(x) <= 9 and abs(y) <= 9:
                rect(img, cx + x, cy + y, 1, 1, (*dk, 255))
            if abs(x) + abs(y) <= 10 and abs(x) <= 7 and abs(y) <= 7:
                rect(img, cx + x, cy + y, 1, 1, PAL["R"] + (255,))
    rect(img, cx - 4, cy - 5, 3, 2, PAL["r"] + (255,))
    # Canos
    for y, c in ((116, dl), (117, dm), (118, dd)):
        rect(img, 0, y, 64, 1, (*c, 255))
    for x in (4, 36):
        rect(img, x, 112, 3, 10, (*dk, 255))
    img.save(os.path.join(ROOT, "bg_tech.png"))


def gen_city():
    # Céu: degradê com dithering, estrelas e lua neon
    W, H = 512, 216
    sky = new(W, H)
    steps = [(6, 0, 20), (20, 0, 48), (44, 4, 76), (76, 10, 96), (110, 20, 110)]
    for y in range(H):
        t = y / (H - 1) * (len(steps) - 1)
        i = min(int(t), len(steps) - 2)
        for x in range(W):
            rect(sky, x, y, 1, 1, (*dither_pick(x, y, t - i, steps[i], steps[i + 1]), 255))
    random.seed(3)
    for _ in range(90):
        x, y = random.randrange(W), random.randrange(110)
        rect(sky, x, y, 1, 1, (200, 200, 255, 255) if random.random() < 0.3 else (120, 120, 170, 255))
    mx, my = 330, 46
    for y in range(-20, 21):
        for x in range(-20, 21):
            d = math.hypot(x, y)
            if d <= 16:
                c = dither_pick(x, y, max(0.0, (d - 6) / 10), (252, 150, 252), (200, 60, 200))
                rect(sky, mx + x, my + y, 1, 1, (*c, 255))
            elif d <= 20 and (x + y) % 2 == 0:
                rect(sky, mx + x, my + y, 1, 1, (120, 30, 130, 255))
    sky.save(os.path.join(ROOT, "bg_sky.png"))

    lights = [PAL["c"], PAL["H"], PAL["y"], (180, 140, 255)]

    def building(img, x, top, w, base, light_chance, rng):
        rect(img, x, top, w, H - top, (*base, 255))
        rect(img, x, top, w, 1, tuple(min(255, v + 30) for v in base) + (255,))
        for wy in range(top + 4, H, 6):
            for wx in range(x + 3, x + w - 3, 5):
                if rng.random() < light_chance:
                    c = rng.choice(lights)
                    rect(img, wx, wy, 2, 2, (c[0] * 3 // 4, c[1] * 3 // 4, c[2] * 3 // 4, 255))

    # Camada distante: silhuetas e a Torre do Relógio da USP
    far = new(W, H)
    rng = random.Random(21)
    x = 0
    while x < W:
        w = rng.randint(24, 52)
        building(far, x, rng.randint(70, 150), w, (34, 14, 66), 0.12, rng)
        x += w + rng.randint(0, 6)
    tx = 400
    rect(far, tx - 5, 30, 10, H - 30, (40, 22, 84, 255))
    rect(far, tx - 7, 26, 14, 6, (40, 22, 84, 255))
    rect(far, tx - 1, 16, 2, 10, (40, 22, 84, 255))
    rect(far, tx - 1, 14, 2, 2, PAL["r"] + (255,))
    for y in range(-3, 4):
        for x2 in range(-3, 4):
            if x2 * x2 + y * y <= 9:
                rect(far, tx + x2, 44 + y, 1, 1, PAL["y"] + (255,))
    rect(far, tx, 42, 1, 3, PAL["k"] + (255,))
    rect(far, tx, 44, 2, 1, PAL["k"] + (255,))
    far.save(os.path.join(ROOT, "bg_far.png"))

    # Camada próxima: prédios, letreiros verticais e o outdoor da Serpentis
    near = new(W, H)
    rng = random.Random(99)
    x = 0
    while x < W:
        w = rng.randint(36, 70)
        top = rng.randint(96, 170)
        building(near, x, top, w, (18, 8, 36), 0.3, rng)
        if rng.random() < 0.45:
            c = rng.choice(lights)
            rect(near, x + 3, top + 8, 4, 28, (*c, 255))
            rect(near, x + 4, top + 9, 2, 26, (255, 255, 255, 255))
        x += w + rng.randint(4, 16)
    bx, by = 160, 70
    rect(near, bx + 46, by + 30, 4, H, (10, 4, 20, 255))
    rect(near, bx, by, 96, 32, (0, 40, 60, 255))
    for xx in range(bx, bx + 96):
        rect(near, xx, by, 1, 1, PAL["c"] + (255,))
        rect(near, xx, by + 31, 1, 1, PAL["c"] + (255,))
    rect(near, bx, by, 1, 32, PAL["c"] + (255,))
    rect(near, bx + 95, by, 1, 32, PAL["c"] + (255,))
    for i in range(10):
        yy = by + 16 + round(math.sin(i * 0.9) * 5)
        rect(near, bx + 6 + i * 3, yy, 3, 3, PAL["e"] + (255,))
    text(near, bx + 40, by + 7, "SERPENTIS", "c")
    text(near, bx + 46, by + 18, "BIOTECH", "H")
    near.save(os.path.join(ROOT, "bg_near.png"))


# --- Barraquinha de dogão ----------------------------------------------------------

def hotdog_frame(open_):
    """Carrinho de cachorro-quente com guarda-sol neon (48x40)."""
    img = new(48, 40)
    # Guarda-sol listrado
    for y in range(2, 11):
        half = round(22 * math.sqrt(max(0.0, 1 - ((10 - y) / 9) ** 2)))
        for x in range(24 - half, 24 + half):
            c = "H" if ((x - 24) // 5) % 2 == 0 else "y"
            if y == 10:
                c = "h" if c == "H" else "Y"
            rect(img, x, y, 1, 1, c)
    rect(img, 23, 11, 2, 11, "g")
    rect(img, 23, 11, 1, 11, "l")
    # Balcão e carrinho
    rect(img, 4, 20, 40, 2, "w")
    rect(img, 4, 22, 40, 1, "g")
    bevel(img, 5, 23, 38, 11, "l", "g", "d")
    rect(img, 8, 25, 32, 7, "k")
    text(img, 9, 26, "DOGÃO", "y" if open_ else "d")
    for x in (12, 36):
        for y in range(-3, 4):
            for dx in range(-3, 4):
                if dx * dx + y * y <= 9:
                    rect(img, x + dx, 36 + y, 1, 1, "D" if dx * dx + y * y > 2 else "g")
    if open_:
        # Dogão no balcão, mostarda, ketchup e fumacinha
        rect(img, 8, 17, 12, 3, "o")
        rect(img, 9, 16, 10, 2, "r")
        rect(img, 10, 16, 8, 1, "y")
        rect(img, 30, 14, 3, 6, "y")
        rect(img, 30, 13, 1, 1, "Y")
        rect(img, 35, 14, 3, 6, "R")
        rect(img, 36, 13, 1, 1, "r")
        for i, (x, y) in enumerate(((11, 13), (14, 11), (12, 9), (16, 12))):
            rect(img, x, y, 1, 1, "w" if i % 2 == 0 else "l")
    else:
        # Fechado: porta de enrolar abaixada
        for y in range(12, 20):
            rect(img, 5, y, 38, 1, "g" if y % 2 == 0 else "d")
    add_outline(img)
    return img


def gen_hotdog():
    img = new(96, 40)
    img.alpha_composite(hotdog_frame(True), (0, 0))
    img.alpha_composite(hotdog_frame(False), (48, 0))
    img.save(os.path.join(ROOT, "hotdog.png"))


# --- Fase 2: Instituto Butantan ---------------------------------------------------

def disc(img, cx, cy, r, c):
    for y in range(-r, r + 1):
        for x in range(-r, r + 1):
            if x * x + y * y <= r * r + r * 0.6:
                rect(img, cx + x, cy + y, 1, 1, c)


def shaded_disc(img, cx, cy, r, base, light, dark, plate=False):
    """Segmento redondo da cobra, com luz em cima e sombra embaixo."""
    disc(img, cx, cy, r, dark)
    disc(img, cx, cy - 1, r - 1, base)
    disc(img, cx - 1, cy - max(1, r // 2), max(1, r // 3), light)
    if plate:
        rect(img, cx - 1, cy - r, 2, r * 2, "g")
        rect(img, cx - 1, cy - r, 1, r * 2, "l")


def boss_head(img, hx, hy, open_mouth):
    """Cabeça da Jararaca-X virada para a direita, com focinho em (hx, hy)."""
    for y in range(-6, 7):
        for x in range(-14, 1):
            if (x / 14.0) ** 2 + (y / 6.0) ** 2 <= 1.0:
                rect(img, hx + x, hy + y, 1, 1, "E" if y > -2 else "e")
    rect(img, hx - 12, hy - 4, 10, 1, "g")  # placa de metal na cabeça
    rect(img, hx - 12, hy - 5, 10, 1, "l")
    rect(img, hx - 6, hy - 2, 3, 2, "r")
    rect(img, hx - 5, hy - 2, 1, 1, "y")
    if open_mouth:
        rect(img, hx - 10, hy + 2, 12, 5, "R")
        rect(img, hx - 9, hy + 3, 10, 3, "r")
        for fx in (hx - 8, hx - 2):
            rect(img, fx, hy + 2, 1, 3, "w")
            rect(img, fx, hy + 5, 1, 2, "w")
    else:
        rect(img, hx - 12, hy + 3, 12, 1, "f")
    rect(img, hx + 1, hy + 1, 3, 1, "H")


def boss_frame(kind, phase=0.0):
    """Quadros 80x48 da Jararaca-X: rastejando (2) e erguida cuspindo (1)."""
    img = new(80, 48)
    if kind == "crawl":
        for i in range(16):
            x = 6 + i * 3.6
            y = 38 + math.sin(phase + i * 0.7) * 2.5
            r = 3 + min(i, 10) * 0.35
            shaded_disc(img, round(x), round(y), round(r), "E", "e", "f", plate=(i % 4 == 3))
        boss_head(img, 76, 35, False)
    else:
        for i in range(10):
            x = 6 + i * 3.4
            y = 40 + math.sin(i * 0.8) * 2
            shaded_disc(img, round(x), round(y), round(3 + i * 0.4), "E", "e", "f", plate=(i % 4 == 3))
        # Pescoço subindo em curva
        for i in range(12):
            t = i / 11
            x = 40 + t * 22 + math.sin(t * math.pi) * 6
            y = 38 - t * 26
            shaded_disc(img, round(x), round(y), 6, "E", "e", "f", plate=(i % 4 == 1))
        boss_head(img, 77, 12, True)
    add_outline(img)
    return img


def gen_boss():
    img = new(240, 48)
    img.alpha_composite(boss_frame("crawl", 0.0), (0, 0))
    img.alpha_composite(boss_frame("crawl", 1.8), (80, 0))
    img.alpha_composite(boss_frame("rear"), (160, 0))
    img.save(os.path.join(ROOT, "boss.png"))


def gen_plant():
    """Planta tropical com flores laranja, como as do Duke Nukem II (32x32)."""
    img = new(32, 32)
    base = (16, 31)
    leaves = [(-14, 14), (-11, 6), (-5, 1), (3, 0), (10, 5), (14, 13), (-8, 18), (8, 18)]
    for tx, ty in leaves:
        steps = 14
        for i in range(steps + 1):
            t = i / steps
            x = base[0] + tx * t
            y = base[1] + (ty - base[1]) * t + math.sin(t * math.pi) * -3
            w = 2 if 0.2 < t < 0.85 else 1
            rect(img, round(x), round(y), w, 2, "E" if i % 3 else "e")
    for fx, fy in ((9, 12), (21, 9), (24, 17), (12, 4)):
        disc(img, fx, fy, 2, "o")
        rect(img, fx, fy, 1, 1, "r")
    rect(img, 15, 24, 2, 8, "f")
    add_outline(img)
    img.save(os.path.join(ROOT, "plant.png"))


def gen_lab_backdrop():
    """Parede do laboratório da Serpentis: painéis esverdeados e tubos de vidro
    com cobras em líquido verde."""
    W, H = 128, 128
    img = new(W, H)
    pl, pm, pd, pk = (86, 104, 96), (60, 76, 70), (38, 50, 46), (22, 30, 28)
    rect(img, 0, 0, W, H, (*pm, 255))
    for x, y, w, h in ((0, 0, 64, 24), (64, 0, 64, 24), (0, 104, 128, 24)):
        bevel(img, x, y, w, h, pl, pm, pd)
    for y in (8, 14):
        rect(img, 6, y, 52, 1, (*pk, 255))
        rect(img, 70, y, 52, 1, (*pk, 255))
    # Dois tubos com cobras
    for tx in (10, 74):
        rect(img, tx - 2, 26, 48, 6, PAL["g"] + (255,))
        rect(img, tx - 2, 26, 48, 1, PAL["l"] + (255,))
        rect(img, tx - 2, 96, 48, 6, PAL["g"] + (255,))
        rect(img, tx - 2, 101, 48, 1, PAL["d"] + (255,))
        for y in range(32, 96):
            for x in range(tx, tx + 44):
                c = dither_pick(x, y, (y - 32) / 64 * 0.7 + 0.15, (20, 90, 40), (10, 50, 24))
                rect(img, x, y, 1, 1, (*c, 255))
        rect(img, tx + 3, 34, 2, 58, (150, 230, 170, 255))
        rect(img, tx + 38, 34, 1, 58, (90, 170, 110, 255))
        for i in range(26):
            x = tx + 22 + round(math.sin(i * 0.55) * 11)
            y = 40 + i * 2
            rect(img, x, y, 3, 3, PAL["f"] + (255,))
            rect(img, x, y, 2, 1, (40, 140, 60, 255))
        for i in range(5):
            rect(img, tx + 8 + i * 7, 88 - (i * 13) % 40, 1, 1, PAL["e"] + (255,))
    rect(img, 60, 30, 6, 70, (*pd, 255))
    rect(img, 61, 30, 1, 70, (*pl, 255))
    img.save(os.path.join(ROOT, "bg_lab.png"))


def gen_butantan_backdrop():
    """Camada próxima da fase 2: o prédio histórico do Instituto Butantan
    entre palmeiras, com iluminação neon da noite de 2087."""
    W, H = 512, 216
    img = new(W, H)
    rng = random.Random(5)
    # Prédio histórico
    bx, by, bw = 150, 112, 210
    facade, shade = (110, 80, 120), (80, 56, 92)
    rect(img, bx, by, bw, H - by, (*facade, 255))
    rect(img, bx - 6, by - 6, bw + 12, 6, (96, 34, 46, 255))   # telhado
    rect(img, bx - 6, by - 7, bw + 12, 1, (140, 60, 70, 255))
    rect(img, bx + 80, by - 22, 50, 16, (*facade, 255))        # frontão central
    rect(img, bx + 76, by - 26, 58, 4, (96, 34, 46, 255))
    for row in range(2):
        for i in range(12):
            wx = bx + 8 + i * 17
            wy = by + 10 + row * 30
            rect(img, wx, wy, 9, 16, (30, 20, 40, 255))
            rect(img, wx + 1, wy - 1, 7, 1, (30, 20, 40, 255))
            if rng.random() < 0.5:
                rect(img, wx + 1, wy + 2, 7, 13, (252, 220, 120, 255) if rng.random() < 0.6 else (84, 252, 252, 255))
            rect(img, wx, wy + 16, 9, 1, (*shade, 255))
    for cx in range(bx + 86, bx + 126, 9):                     # colunas da entrada
        rect(img, cx, by + 70, 4, H - by - 70, (150, 120, 160, 255))
    text(img, bx + 47, by - 18, "INSTITUTO BUTANTAN", "e", shadow="f")
    # Palmeiras
    for px in (30, 96, 400, 470):
        h = rng.randint(90, 120)
        for y in range(H - h, H):
            rect(img, px + round(math.sin(y * 0.05) * 2), y, 3, 1, (40, 26, 30, 255))
        top = (px + 1, H - h)
        for ang in range(0, 360, 40):
            a = math.radians(ang)
            for t in range(1, 20):
                x = top[0] + math.cos(a) * t
                y = top[1] + math.sin(a) * t * 0.5 + t * t * 0.03
                rect(img, round(x), round(y), 2, 1, (10, 70, 40, 255) if t % 3 else (20, 110, 60, 255))
    img.save(os.path.join(ROOT, "bg_butantan.png"))


# --- Fase 3: Cidade Universitária -------------------------------------------------

def gen_platform():
    """Plataforma móvel 48x20 (3 blocos) com propulsores; 2 quadros de chama."""
    img = new(96, 20)
    for f in range(2):
        o = f * 48
        rect(img, o, 0, 48, 1, "w")
        rect(img, o, 1, 48, 2, "l")
        rect(img, o, 3, 48, 1, "d")
        hazard(img, o, 4, 48, 4)
        rect(img, o, 8, 48, 1, "k")
        rect(img, o + 2, 9, 44, 4, "D")
        for tx in (8, 36):
            rect(img, o + tx, 9, 5, 4, "g")
            rect(img, o + tx, 9, 5, 1, "l")
            flame = 4 if f == 0 else 6
            rect(img, o + tx + 1, 13, 3, flame, "c")
            rect(img, o + tx + 2, 13, 1, flame - 1, "w")
        rect(img, o + 22, 10, 4, 2, "r" if f == 0 else "R")
    img.save(os.path.join(ROOT, "platform.png"))


def clock_frame(hand_angle, angry=False):
    """CRONOS-X: o relógio da torre virou um drone gigante (64x48)."""
    img = new(64, 48)
    cx, cy, r = 32, 26, 19
    # Rotores
    for rx in (10, 54):
        rect(img, rx - 1, 4, 3, 6, "d")
        span = 9 if hand_angle % 2 < 1 else 5
        rect(img, rx - span, 3, span * 2, 1, "l")
    rect(img, 9, 8, 46, 3, "d")
    rect(img, 9, 8, 46, 1, "g")
    # Caixa do relógio
    disc(img, cx, cy, r + 2, "Y")
    disc(img, cx, cy - 1, r + 1, "y")
    face = (252, 170, 170) if angry else PAL["w"]
    disc(img, cx, cy, r - 2, face)
    for i in range(12):
        a = i * math.pi / 6
        px = cx + round(math.cos(a) * (r - 4))
        py = cy + round(math.sin(a) * (r - 4))
        rect(img, px, py, 1 if i % 3 else 2, 1 if i % 3 else 2, "k")
    for length, ang in ((r - 6, hand_angle), (r - 10, hand_angle * 0.3 + 1.0)):
        for t in range(length):
            rect(img, cx + round(math.cos(ang) * t), cy + round(math.sin(ang) * t), 1, 1, "k")
    disc(img, cx, cy, 4, "R")
    disc(img, cx, cy, 2, "r")
    rect(img, cx - 1, cy - 1, 1, 1, "w")
    # Canhões e luz de baixo
    for gx in (12, 48):
        rect(img, gx - 2, 38, 5, 6, "d")
        rect(img, gx - 2, 38, 5, 1, "g")
        rect(img, gx - 1, 44, 3, 2, "R" if angry else "D")
    rect(img, 22, 44, 20, 2, "H")
    add_outline(img)
    return img


def gen_clock_boss():
    img = new(192, 48)
    img.alpha_composite(clock_frame(0.4), (0, 0))
    img.alpha_composite(clock_frame(1.9), (64, 0))
    img.alpha_composite(clock_frame(3.3, angry=True), (128, 0))
    img.save(os.path.join(ROOT, "boss_clock.png"))


def gen_usp_backdrop():
    """Camada próxima da fase 3: prédios de concreto sobre pilotis, árvores
    do campus e o letreiro da USP."""
    W, H = 512, 216
    img = new(W, H)
    rng = random.Random(8)
    concrete, dark = (78, 70, 96), (52, 46, 66)
    x = 10
    while x < W - 40:
        w = rng.randint(70, 120)
        top = rng.randint(100, 140)
        base = top + rng.randint(40, 55)
        rect(img, x, top, w, base - top, (*concrete, 255))
        rect(img, x, top, w, 2, (110, 100, 130, 255))
        for wy in range(top + 6, base - 4, 9):
            rect(img, x + 3, wy, w - 6, 4, (*dark, 255))
            for wx in range(x + 4, x + w - 6, 6):
                if rng.random() < 0.35:
                    c = rng.choice([(252, 220, 120), (84, 252, 252), (252, 84, 252)])
                    rect(img, wx, wy + 1, 4, 2, (*c, 255))
        for px in range(x + 6, x + w - 4, 16):  # pilotis
            rect(img, px, base, 4, H - base, (*dark, 255))
        x += w + rng.randint(20, 40)
    for tx in range(20, W, 47):  # árvores
        cy = H - rng.randint(28, 44)
        rect(img, tx, cy, 3, H - cy, (40, 26, 30, 255))
        for _ in range(160):
            a = rng.random() * math.tau
            d = math.sqrt(rng.random()) * 15
            rect(img, tx + 1 + round(math.cos(a) * d * 1.3), cy + round(math.sin(a) * d * 0.8),
                 2, 2, (12, 64, 40, 255) if rng.random() < 0.7 else (24, 100, 56, 255))
    rect(img, 236, 70, 40, 18, (10, 4, 20, 255))
    for xx in range(236, 276):
        rect(img, xx, 70, 1, 1, PAL["y"] + (255,))
        rect(img, xx, 87, 1, 1, PAL["y"] + (255,))
    text(img, 247, 76, "USP", "y")
    rect(img, 254, 88, 4, 40, (10, 4, 20, 255))
    img.save(os.path.join(ROOT, "bg_usp.png"))


def main():
    os.makedirs(ROOT, exist_ok=True)
    gen_font()
    gen_hero()
    gen_enemies()
    gen_items()
    gen_hotdog()
    gen_boss()
    gen_plant()
    gen_lab_backdrop()
    gen_butantan_backdrop()
    gen_platform()
    gen_clock_boss()
    gen_usp_backdrop()
    gen_portrait()
    gen_tiles()
    gen_tech_backdrop()
    gen_city()
    print("Arte gerada em", os.path.normpath(ROOT))


if __name__ == "__main__":
    main()

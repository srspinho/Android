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
HERO_FRAMES = [
    (HERO_UPPER, "stand"),
    (HERO_UPPER, "runA"),
    (HERO_UPPER, "runB"),
    (HERO_UPPER, "runC"),
    (HERO_UPPER, "jump"),
    (HERO_BACK, "stand"),
    (HERO_BACK, "climb2"),
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
}
ITEM_ORDER = ["coxinha", "card", "turbo", "chip"]


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
    "metro",
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


def main():
    os.makedirs(ROOT, exist_ok=True)
    gen_font()
    gen_hero()
    gen_enemies()
    gen_items()
    gen_portrait()
    gen_tiles()
    gen_tech_backdrop()
    gen_city()
    print("Arte gerada em", os.path.normpath(ROOT))


if __name__ == "__main__":
    main()

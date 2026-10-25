#!/usr/bin/env python3
"""Gera os efeitos sonoros e as músicas do jogo (estilo chiptune/synthwave).

Uso:  python3 tools/gen_audio.py      (precisa do numpy: pip install numpy)

Tudo é sintetizado: ondas quadradas, dente-de-serra, triangulares e ruído, como
nos chips de som dos anos 90. As músicas são descritas em TRACKS (andamento,
tom, acordes e batida); mude ali e rode o script de novo.
Saída: audio/sfx/*.wav e audio/music/*.wav (as músicas tocam em loop).
"""
import os
import random
import wave

import numpy as np

SR = 22050
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "audio")


# --- Blocos básicos ---------------------------------------------------------------

def midi(m):
    return 440.0 * 2 ** ((m - 69) / 12)


def secs(n):
    return np.arange(n) / SR


def samples(seconds):
    return max(1, int(seconds * SR))


def phase(freq, n):
    f = np.broadcast_to(np.asarray(freq, dtype=float), (n,))
    return np.cumsum(f) / SR


def square(ph, duty=0.5):
    return np.where((ph % 1.0) < duty, 1.0, -1.0)


def saw(ph):
    return 2.0 * (ph % 1.0) - 1.0


def tri(ph):
    return 2.0 * np.abs(2.0 * (ph % 1.0) - 1.0) - 1.0


def sine(ph):
    return np.sin(2 * np.pi * ph)


def noise(n, seed=0):
    return np.random.default_rng(seed).uniform(-1, 1, n)


def env(n, attack=0.005, decay=0.1):
    """Envelope: sobe em `attack` segundos e cai exponencialmente."""
    tt = secs(n)
    return np.clip(tt / max(attack, 1e-4), 0, 1) * np.exp(-tt / decay)


def lowpass(x, k):
    """Filtro passa-baixa simples (média móvel de k amostras)."""
    if k <= 1:
        return x
    return np.convolve(x, np.ones(k) / k, mode="same")


def sweep(f0, f1, n):
    return f0 * (f1 / f0) ** (np.arange(n) / n)


def vibrato(freq, n, rate=6.0, depth=0.01):
    return freq * (1 + depth * np.sin(2 * np.pi * rate * secs(n)))


def normalize(x, peak=0.9):
    m = np.max(np.abs(x))
    return x * (peak / m) if m > 0 else x


def write(path, x):
    data = (np.clip(x, -1, 1) * 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())


def seq(notes, voice):
    """Toca uma lista de (nota MIDI, duração) com a função voice(freq, n)."""
    parts = [voice(midi(m), samples(d)) for m, d in notes]
    return np.concatenate(parts)


# --- Efeitos sonoros ------------------------------------------------------------

def blip(duty=0.25, decay=0.04):
    return lambda f, n: square(phase(f, n), duty) * env(n, 0.002, decay)


def sfx_shoot():
    n = samples(0.13)
    x = square(phase(sweep(1400, 300, n), n), 0.25) * env(n, 0.001, 0.05)
    return x + 0.3 * noise(n, 1) * env(n, 0.001, 0.015)


def sfx_enemy_shoot():
    n = samples(0.16)
    return lowpass(saw(phase(sweep(700, 180, n), n)) * env(n, 0.002, 0.06), 3)


def sfx_hit():
    n = samples(0.06)
    return lowpass(noise(n, 2) * env(n, 0.001, 0.015), 2)


def sfx_explode():
    n = samples(0.7)
    boom = sine(phase(sweep(120, 35, n), n)) * env(n, 0.002, 0.25)
    rumble = lowpass(noise(n, 3), 6) * env(n, 0.002, 0.18)
    crackle = noise(n, 4) * (noise(n, 5) > 0.92) * env(n, 0.01, 0.12)
    return 0.8 * boom + rumble + 0.4 * crackle


def sfx_jump():
    n = samples(0.11)
    return square(phase(sweep(260, 620, n), n), 0.5) * env(n, 0.002, 0.06)


def sfx_hurt():
    n = samples(0.25)
    f = vibrato(sweep(500, 120, n), n, 30, 0.08)
    return square(phase(f, n), 0.5) * env(n, 0.002, 0.1) + 0.3 * noise(n, 6) * env(n, 0.001, 0.04)


def sfx_pickup():
    return seq([(84, 0.045), (88, 0.045), (91, 0.07)], blip())


def sfx_health():
    voice = lambda f, n: (0.6 * square(phase(f, n), 0.5) + 0.6 * tri(phase(f / 2, n))) * env(n, 0.003, 0.08)
    return seq([(72, 0.06), (76, 0.06), (79, 0.06), (84, 0.14)], voice)


def sfx_card():
    return seq([(79, 0.05), (83, 0.05), (86, 0.05), (91, 0.05), (95, 0.2)], blip(0.25, 0.08))


def sfx_powerup():
    n = samples(0.45)
    f = vibrato(sweep(220, 1760, n), n, 12, 0.03)
    return square(phase(f, n), 0.5) * env(n, 0.01, 0.4)


def sfx_door_open():
    n = samples(0.35)
    whoosh = lowpass(noise(n, 7), 4) * env(n, 0.02, 0.15)
    return whoosh + 0.5 * saw(phase(sweep(300, 80, n), n)) * env(n, 0.005, 0.12)


def sfx_denied():
    beep = lambda f, n: square(phase(f, n), 0.5) * np.where(secs(n) < 0.09, 1.0, 0.0)
    return seq([(49, 0.14), (49, 0.14)], beep) * 0.8


def sfx_hotdog():
    voice = lambda f, n: (square(phase(f, n), 0.5) * 0.6 + tri(phase(f / 2, n)) * 0.5) * env(n, 0.003, 0.12)
    return seq([(72, 0.07), (76, 0.07), (79, 0.07), (84, 0.1), (79, 0.07), (84, 0.25)], voice)


def sfx_boss_spit():
    n = samples(0.3)
    return lowpass(noise(n, 8), 3) * env(n, 0.005, 0.1) + 0.5 * saw(phase(sweep(400, 100, n), n)) * env(n, 0.005, 0.08)


def sfx_boss_roar():
    n = samples(0.9)
    f = vibrato(sweep(80, 45, n), n, 6, 0.1)
    x = saw(phase(f, n)) + 0.5 * saw(phase(f * 1.01, n)) + 0.6 * lowpass(noise(n, 9), 8)
    return np.tanh(2.0 * x * env(n, 0.05, 0.5))


def sfx_level_complete():
    lead = seq([(72, 0.12), (76, 0.12), (79, 0.12), (84, 0.3), (79, 0.12), (84, 0.7)], blip(0.5, 0.25))
    bass_voice = lambda f, n: tri(phase(f, n)) * env(n, 0.005, 0.4)
    bass = seq([(48, 0.36), (53, 0.42), (48, 0.7)], bass_voice)
    out = np.zeros(max(len(lead), len(bass)))
    out[: len(lead)] += lead
    out[: len(bass)] += 0.8 * bass
    return out


def sfx_death():
    voice = lambda f, n: square(phase(vibrato(f, n, 7, 0.02), n), 0.5) * env(n, 0.005, 0.25)
    return seq([(76, 0.15), (72, 0.15), (67, 0.15), (60, 0.6)], voice)


SFX = {
    "shoot": (sfx_shoot, 0.5),
    "enemy_shoot": (sfx_enemy_shoot, 0.4),
    "hit": (sfx_hit, 0.4),
    "explode": (sfx_explode, 0.8),
    "jump": (sfx_jump, 0.35),
    "hurt": (sfx_hurt, 0.6),
    "pickup": (sfx_pickup, 0.45),
    "health": (sfx_health, 0.5),
    "card": (sfx_card, 0.5),
    "powerup": (sfx_powerup, 0.5),
    "door_open": (sfx_door_open, 0.6),
    "denied": (sfx_denied, 0.45),
    "hotdog": (sfx_hotdog, 0.55),
    "boss_spit": (sfx_boss_spit, 0.55),
    "boss_roar": (sfx_boss_roar, 0.85),
    "level_complete": (sfx_level_complete, 0.7),
    "death": (sfx_death, 0.7),
}


# --- Músicas -----------------------------------------------------------------------

MINOR = [0, 2, 3, 5, 7, 8, 10]
HARMONIC_MINOR = [0, 2, 3, 5, 7, 8, 11]

TRACKS = {
    # Fase 1: synthwave noturno em lá menor (Am F C G)
    "fase1": dict(
        bpm=112, root=57, scale=MINOR, seed=1,
        chords=[(0, "m"), (-4, "M"), (3, "M"), (-2, "M")],
        bass=[0, 0, 12, 0, 0, 12, 0, 12],
        arp=[0, 1, 2, 3, 4, 3, 2, 1],
        kick="x...x...x...x...", snare="....x.......x...", hat="..x...x...x...x.",
    ),
    # Fase 2: clima de encantador de serpentes em ré menor harmônica
    "fase2": dict(
        bpm=100, root=50 + 12, scale=HARMONIC_MINOR, seed=2,
        chords=[(0, "m"), (1, "M"), (0, "m"), (-2, "M")],
        bass=[0, None, 0, 7, 0, None, 1, 0],
        arp=[0, 2, 1, 2, 0, 2, 1, 3],
        kick="x.....x...x.....", snare="....x.......x..x", hat="x.x.x.x.x.x.x.x.",
    ),
    # Fase 3: animado, em mi menor (Em C G D)
    "fase3": dict(
        bpm=124, root=52 + 12, scale=MINOR, seed=3,
        chords=[(0, "m"), (-4, "M"), (3, "M"), (-2, "M")],
        bass=[0, 12, 0, 12, 0, 12, 7, 12],
        arp=[0, 1, 2, 4, 3, 2, 1, 2],
        kick="x...x...x...x.x.", snare="....x.......x...", hat="xxx.xxx.xxx.xxx.",
    ),
    # Chefes: rápido e tenso em dó menor
    "boss": dict(
        bpm=150, root=48 + 12, scale=MINOR, seed=4,
        chords=[(0, "m"), (0, "m"), (-4, "M"), (-2, "M")],
        bass=[0, 0, 0, 12, 0, 0, 12, 10],
        arp=[0, 1, 2, 1, 3, 1, 2, 1],
        kick="x.x.x.x.x.x.x.x.", snare="....x.......x.xx", hat="xxxxxxxxxxxxxxxx",
    ),
}

QUALITY = {"m": [0, 3, 7], "M": [0, 4, 7]}


def add(buf, at, x):
    end = min(len(buf), at + len(x))
    buf[at:end] += x[: end - at]


def kick(n):
    return sine(phase(sweep(160, 45, n), n)) * env(n, 0.001, 0.07)


def snare(n):
    return 0.7 * lowpass(noise(n, 11), 2) * env(n, 0.001, 0.07) + 0.4 * sine(phase(190, n)) * env(n, 0.001, 0.05)


def hat(n):
    nz = noise(n, 12)
    return (nz - lowpass(nz, 3)) * env(n, 0.001, 0.015)


def make_melody(spec, bars):
    """Frases de 2 compassos: notas dos acordes nos tempos fortes e graus
    vizinhos da escala no meio, com ritmo sorteado (mas fixo pela semente)."""
    rng = random.Random(spec["seed"])
    scale = spec["scale"]
    rhythms = [
        [4, 2, 2, 4, 4], [2, 2, 2, 2, 4, 4], [6, 2, 4, 4], [4, 4, 2, 2, 4], [3, 3, 2, 4, 4],
    ]
    phrases = []
    for p in range(2):
        notes = []
        for bar in range(2):
            chord_off, qual = spec["chords"][(p * 2 + bar) % len(spec["chords"])]
            tones = [chord_off + i for i in QUALITY[qual]]
            step = 0
            for i, dur in enumerate(rng.choice(rhythms)):
                if i == 0 or rng.random() < 0.5:
                    pitch = rng.choice(tones) + 12
                else:
                    deg = rng.randrange(len(scale))
                    pitch = scale[deg] + 12
                if rng.random() < 0.12 and i > 0:
                    pitch = None  # pausa
                notes.append((bar * 16 + step, dur, pitch))
                step += dur
        phrases.append(notes)
    return phrases


def render_track(spec, bars=16):
    step = 60.0 / spec["bpm"] / 4
    total = samples(bars * 16 * step)
    buf = np.zeros(total + samples(2.0))
    root = spec["root"]
    ns = lambda steps: samples(steps * step)

    melody = make_melody(spec, bars)
    for bar in range(bars):
        chord_off, qual = spec["chords"][bar % len(spec["chords"])]
        tones = [root + chord_off + i for i in QUALITY[qual]]
        bar_at = bar * 16
        # Pad: acorde com duas serras desafinadas
        n = ns(16)
        pad = np.zeros(n)
        for t_ in tones:
            f = midi(t_ - 12)
            pad += saw(phase(f, n)) + saw(phase(f * 1.006, n))
        pad *= np.clip(secs(n) / 0.4, 0, 1) * np.clip((n - np.arange(n)) / samples(0.2), 0, 1)
        add(buf, samples(bar_at * step), 0.035 * lowpass(pad, 10))
        # Baixo em colcheias
        for i, off in enumerate(spec["bass"]):
            if off is None:
                continue
            n = ns(1.8)
            f = midi(root - 24 + chord_off + off)
            b = (0.6 * saw(phase(f, n)) + 0.5 * square(phase(f, n), 0.5)) * env(n, 0.004, 0.22)
            add(buf, samples((bar_at + i * 2) * step), 0.32 * lowpass(b, 6))
        # Arpejo em semicolcheias
        arp_tones = tones + [t_ + 12 for t_ in tones]
        for s in range(16):
            m = arp_tones[spec["arp"][s % len(spec["arp"])] % len(arp_tones)] + 12
            n = ns(0.9)
            add(buf, samples((bar_at + s) * step), 0.11 * square(phase(midi(m), n), 0.25) * env(n, 0.002, 0.07))
        # Bateria
        for s in range(16):
            at = samples((bar_at + s) * step)
            if spec["kick"][s] == "x":
                add(buf, at, 0.75 * kick(samples(0.18)))
            if spec["snare"][s] == "x":
                add(buf, at, 0.5 * snare(samples(0.14)))
            if spec["hat"][s] == "x":
                add(buf, at, 0.22 * hat(samples(0.04)))
        # Melodia a partir do 5º compasso
        if bar >= 4 and bar % 2 == 0:
            phrase = melody[(bar // 2) % len(melody)]
            for start, dur, pitch in phrase:
                if pitch is None:
                    continue
                n = ns(dur * 0.95)
                f = vibrato(midi(root + pitch), n, 5.5, 0.004)
                lead = square(phase(f, n), 0.5) * (0.35 + 0.65 * env(n, 0.01, 0.25))
                lead *= np.clip((n - np.arange(n)) / samples(0.03), 0, 1)
                add(buf, samples((bar_at + start) * step), 0.15 * lowpass(lead, 2))

    # Loop sem emenda: o que passou do fim volta para o começo.
    tail = buf[total:]
    buf[: len(tail)] += tail
    out = buf[:total]
    return normalize(np.tanh(out * 1.2), 0.85)


def main():
    os.makedirs(os.path.join(ROOT, "sfx"), exist_ok=True)
    os.makedirs(os.path.join(ROOT, "music"), exist_ok=True)
    for name, (fn, vol) in SFX.items():
        x = normalize(fn(), vol)
        fade = min(len(x), samples(0.015))  # evita clique no fim do som
        x[-fade:] *= np.linspace(1, 0, fade)
        write(os.path.join(ROOT, "sfx", name + ".wav"), x)
    for name, spec in TRACKS.items():
        write(os.path.join(ROOT, "music", name + ".wav"), render_track(spec))
    print("Áudio gerado em", os.path.normpath(ROOT))


if __name__ == "__main__":
    main()

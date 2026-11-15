"""Genera il fruscio di sintonizzazione di Frequenza (il candidato «C2»).

È un fruscio morbido e ovattato, senza fischi: il timbro scivola piano dal
cupo al chiaro e le stazioni affiorano appena. Dura circa 7,4 secondi, e la
fine sfuma nell'inizio, così in loop non si sente lo stacco. È mono, a
44,1 kHz e 16 bit. Seme e parametri sono fissi: rigenerarlo dà sempre lo
stesso file.

Uso: python3 tool/tuning_sound/generate.py android/app/src/main/res/raw/tuning_static.wav
"""
import math
import random
import struct
import sys
import wave

RATE = 44100
SECONDS = 8.0
N = int(RATE * SECONDS)
LOOP_FADE = int(RATE * 0.6)


class Biquad:
    """Filtro biquad (RBJ): passa-banda, passa-basso o passa-alto."""

    def __init__(self, kind, freq, q):
        w = 2 * math.pi * freq / RATE
        alpha = math.sin(w) / (2 * q)
        c = math.cos(w)
        if kind == 'band':
            b0, b1, b2 = alpha, 0, -alpha
        elif kind == 'low':
            b0, b1, b2 = (1 - c) / 2, 1 - c, (1 - c) / 2
        else:
            b0, b1, b2 = (1 + c) / 2, -(1 + c), (1 + c) / 2
        a0, a1, a2 = 1 + alpha, -2 * c, 1 - alpha
        self.b = (b0 / a0, b1 / a0, b2 / a0)
        self.a = (a1 / a0, a2 / a0)
        self.x1 = self.x2 = self.y1 = self.y2 = 0.0

    def __call__(self, x):
        b0, b1, b2 = self.b
        a1, a2 = self.a
        y = b0 * x + b1 * self.x1 + b2 * self.x2 - a1 * self.y1 - a2 * self.y2
        self.x2, self.x1, self.y2, self.y1 = self.x1, x, self.y1, y
        return y


def smooth_random(rate_hz, rng):
    """Un valore tra 0 e 1 che cambia piano, a circa [rate_hz] variazioni al secondo."""
    points = [rng.random() for _ in range(int(SECONDS * rate_hz) + 3)]

    def at(t):
        p = t * rate_hz
        i = int(p)
        f = p - i
        f = f * f * (3 - 2 * f)
        return points[i] * (1 - f) + points[i + 1] * f

    return at


def render(name, hiss_band, hiss_level, stations, whistle, warble, fading,
           crackle, voice_level, music_level, seed, tone=None):
    rng = random.Random(seed)
    # tone = (cupo, chiaro, variazioni al secondo): il passa-basso del
    # fruscio si sposta piano tra i due estremi.
    tone_at = smooth_random(tone[2], rng) if tone else None
    hiss_filters = [Biquad('high', hiss_band[0], 0.7), Biquad('low', hiss_band[1], 0.7)]
    voice_formants = [Biquad('band', 700, 4), Biquad('band', 1200, 5), Biquad('band', 2500, 6)]
    voice_lp = Biquad('low', 3000, 0.7)
    fade = smooth_random(0.35, rng)
    syllables = smooth_random(5.0, rng)
    # La manopola scorre: ogni stazione si incontra a un certo istante; prima e
    # dopo se ne sente il fischio di battimento, che scende fino a zero e risale.
    carriers = sorted(rng.uniform(0.6, SECONDS - 0.6) for _ in range(stations))
    out = []
    phase = 0.0
    music_phases = [0.0, 0.0, 0.0]
    music_notes = [220.0, 277.18, 329.63]
    for n in range(N):
        t = n / RATE
        noise = rng.gauss(0, 1)
        if tone_at and n % 64 == 0:
            cutoff = tone[0] * (tone[1] / tone[0]) ** tone_at(t)
            moved = Biquad('low', cutoff, 0.8)
            moved.x1, moved.x2, moved.y1, moved.y2 = (
                hiss_filters[1].x1, hiss_filters[1].x2,
                hiss_filters[1].y1, hiss_filters[1].y2)
            hiss_filters[1] = moved
        h = noise
        for f in hiss_filters:
            h = f(h)
        level = 1.0 - fading * fade(t)
        sample = h * hiss_level * level

        # La stazione più vicina sulla manopola.
        near = min(carriers, key=lambda c: abs(c - t))
        dt = t - near
        closeness = math.exp(-(dt / 0.45) ** 2)
        if whistle > 0:
            beat = 60 + 3200 * min(abs(dt) / 0.9, 1.0)
            beat *= 1 + warble * math.sin(2 * math.pi * 6.5 * t)
            phase += 2 * math.pi * beat / RATE
            whistle_env = math.exp(-(dt / 0.7) ** 2) * (1 - closeness * 0.85)
            sample += whistle * whistle_env * math.sin(phase)

        # Al centro della stazione si sente per un attimo il programma.
        if closeness > 0.02:
            v = noise
            v = sum(f(v) for f in voice_formants)
            v = voice_lp(v)
            gate = max(0.0, syllables(t) - 0.35) * 1.6
            sample += voice_level * closeness * gate * v
            m = 0.0
            for i, note in enumerate(music_notes):
                music_phases[i] += 2 * math.pi * note / RATE
                m += math.sin(music_phases[i]) * (0.6 + 0.4 * math.sin(2 * math.pi * 0.5 * t + i))
            sample += music_level * closeness * m / 3

        if crackle and rng.random() < crackle / RATE:
            sample += rng.choice((-1, 1)) * rng.uniform(0.3, 0.8)
        out.append(sample)

    # Ripetibile senza stacco: gli ultimi istanti sfumano nell'inizio.
    for i in range(LOOP_FADE):
        k = i / LOOP_FADE
        out[i] = out[i] * k + out[N - LOOP_FADE + i] * (1 - k)
    out = out[: N - LOOP_FADE]

    peak = max(abs(s) for s in out) or 1.0
    gain = 0.6 / peak
    with wave.open(name, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b''.join(
            struct.pack('<h', int(max(-1, min(1, s * gain)) * 32767)) for s in out))


def main(out_path):
    render(out_path, hiss_band=(150, 2200), hiss_level=1.0, stations=3,
           whistle=0.0, warble=0.0, fading=0.35, crackle=0, voice_level=0.6,
           music_level=0.35, seed=3, tone=(900, 4200, 0.6))


if __name__ == '__main__':
    main(sys.argv[1])

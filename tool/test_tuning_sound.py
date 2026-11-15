"""Il fruscio di sintonizzazione: formato, durata, niente saturazione, loop senza salti."""

import importlib.util
import struct
import tempfile
import unittest
import wave
from pathlib import Path

GENERATOR = Path(__file__).resolve().parent / 'tuning_sound' / 'generate.py'


def load_generator():
    spec = importlib.util.spec_from_file_location('generate', GENERATOR)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class TuningSoundTest(unittest.TestCase):
    def test_generates_a_soft_loop(self):
        generator = load_generator()
        with tempfile.TemporaryDirectory() as folder:
            first, second = Path(folder) / 'a.wav', Path(folder) / 'b.wav'
            generator.main(str(first))
            generator.main(str(second))
            self.assertEqual(first.read_bytes(), second.read_bytes())
            with wave.open(str(first)) as sound:
                self.assertEqual(sound.getnchannels(), 1)
                self.assertEqual(sound.getframerate(), 44100)
                self.assertEqual(sound.getsampwidth(), 2)
                frames = sound.getnframes()
                data = sound.readframes(frames)
        self.assertGreaterEqual(frames / 44100, 7.2)
        self.assertLessEqual(frames / 44100, 7.6)
        samples = struct.unpack(f'<{frames}h', data)
        self.assertLessEqual(max(map(abs, samples)), 0.62 * 32767)
        self.assertLessEqual(abs(samples[-1] - samples[0]), 0.1 * 32767)


if __name__ == '__main__':
    unittest.main()

# Suono di sintonizzazione — design breve

Data: 15 novembre 2026. Stato: **approvato da Davide**. Branch `feat/suono-sintonia`, costruito sopra `feat/notifica-in-pausa`.

Legenda:
- **[D]** decisione di Davide;
- **[C]** scelta di Claude.

## Intento

Il rumore del volo oggi sembra «un gracchio messo lì a ripetizione», non fluido e lontano da una radio vera che si sintonizza **[D]**. Le cause:
- è un campione di 1 secondo (mono, 22 kHz) ripetuto in loop;
- è fruscio piatto;
- si ferma di colpo e la stazione entra di scatto.

## Decisioni

- **Il suono è il candidato C2** **[D]**:
  - fruscio morbido e ovattato, senza fischi;
  - il timbro scivola piano dal cupo al chiaro, circa ogni due secondi;
  - le stazioni affiorano piano;
  - circa 7,4 secondi, con la fine che sfuma nell'inizio.
- **Un modo migliore di suonarlo** **[D]**:
  - all'atterraggio il fruscio sfuma mentre la stazione sale in dissolvenza;
  - ogni volo parte da un punto diverso del suono;
  - il volume è tarabile.

## Approcci per il suono

1. **Scelto: generato da uno script nel repo** **[C]**. `tool/tuning_sound/generate.py` produce `android/app/src/main/res/raw/tuning_static.wav` con parametri e seme fissi, e il file generato si versiona.
   - È riproducibile e regolabile.
   - Non ci sono licenze di terzi.
2. **Scartato: solo il file WAV.** Per ritoccarlo bisognerebbe ricostruirlo da zero.
3. **Scartato: registrazione esterna.** Davide ha scelto un suono costruito da noi.

## Come **[C]**

- **Script:** lo script di prova, ridotto alla sola configurazione C2. È in Python puro, perché sulla VPS non ci sono numpy né ffmpeg. Ha un test in `tool/test_tuning_sound.py`, eseguito da `check.sh`, che controlla:
  - formato mono a 44,1 kHz, 16 bit;
  - durata di circa 7,4 s;
  - nessuna saturazione;
  - giuntura del loop senza salto.
- **Riproduzione nativa (`MainActivity.kt`):** `MediaPlayer` al posto di `SoundPool`, che non sa partire da un punto qualsiasi del suono.
  - In loop, con partenza da un punto a caso.
  - Volume in una costante (`TUNING_VOLUME = 0.42f`, come oggi).
  - Lo stop sfuma in **400 ms**. Uscendo dall'app (`onStop`) si ferma subito, come oggi.
- **Ingresso della stazione (`JustAudioService.land`):** il volume del player sale da 0 a 1 in **400 ms**, a piccoli passi, insieme alla sfumatura del fruscio. Una nuova sintonia o una pausa durante la salita la interrompono, e il volume torna alle regole attuali (muto in volo, ridotto con il ducking).

## Fuori

Fischi, scariche e onde corte (candidati A e B): non scelti.

## Da verificare sul telefono

- il suono durante un volo lungo, compreso il passaggio di fine loop;
- la dissolvenza all'atterraggio;
- che due voli di fila non suonino identici.

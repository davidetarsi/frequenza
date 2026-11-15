# Macchine a stati esplicite — analisi e direzione

Data: 15 novembre 2026. Stato: **fatto in Frequenza il 15 novembre 2026** (piano `docs/superpowers/plans/2026-11-15-macchine-a-stati.md`); **da portare nello starter**. Davide ha deciso di anticipare l'intervento e di farlo prima in Frequenza. Si fa dopo la pubblicazione sul Play Store e prima della ricerca per paese **[D]**. La convenzione entra prima nello starter **[D]**; la spec di dettaglio per Frequenza si scrive quando si fa l'intervento.

Legenda: **[D]** = deciso da Davide; **[C]** = scelta proposta da Claude.

## Intento

Rendere esplicite le macchine a stati che oggi esistono solo nell'ordine delle righe di codice. Il criterio è valorizzare insieme tre esperienze, senza sacrificarne nessuna:
- **UX:** chi usa l'app;
- **DX:** chi sviluppa;
- **AX:** l'agente che lavora sul codice ripartendo da zero.

La regola che ne esce va riportata nello starter **[D]**.

## Macchine a stati trovate

1. **Sessione radio** (`radio_controller.dart`, `radio_player_state.dart`). È la principale.
   - Lo stato combina:
     - `status`, con 6 valori;
     - `flight`, con 3 valori;
     - `station`, facoltativa;
     - `trackTitle`;
     - il viaggio: partenza, tratta, storico, viaggi e pila «indietro».
   - Nel controller ci sono anche quattro informazioni private:
     - `_currentTuneToken`: il volo valido;
     - `_landed`: l'ultima stazione atterrata;
     - `_Flight`: avanti, indietro o riconnessione;
     - un blocco implicito che ignora gli eventi audio mentre `status == tuning`.
   - Gli stati reali sono 7: spenta, in volo, segnale perso con nuovo tentativo, in onda, in pausa, ricarica in onda, volo fallito. Il tipo ne ammette circa 36. Per esempio `tuning` + `grounded`, `playing` senza stazione, `idle` con stazione: oggi non sono raggiungibili, ma niente lo garantisce.
2. **Motore audio** (`just_audio_service.dart`):
   - `_muted` significa anche «in volo»: una pausa a radio muta interrompe il volo;
   - `_tuningSoundRequest` dice se il fruscio è acceso;
   - `_ducked` dice se il volume è abbassato.
3. **Notifica** (`radio_audio_handler.dart`):
   - `_flying` e `_saved`;
   - `_flying` è scritto da due parti: `showFlight()` dal motore audio e `showControls()` dal ponte.
4. **Schermata** (`radio_page.dart`): ricostruisce lo stato con ternari annidati (titolo, paese, etichetta della manopola, `busy`, `idle`, `flying`). Il compilatore non segnala i testi da aggiornare quando nasce uno stato nuovo.
5. **Preferiti e tema** (`favorites_controller.dart`, `app_theme_mode.dart`): usano `AsyncValue`, quindi la macchina è già esplicita. Lo schema `_generation` + `copyWithPrevious` è però duplicato.
6. **Animazioni e orologio** (puntini di `journey_texts`, timer dell'ora locale, ciclo di `route_map`): stati piccoli e locali ai widget.

**Problema comune ai punti 1–3:** «la radio è in volo» è detto in quattro posti.

| Dove | Come lo dice |
|---|---|
| controller | `flight == flying` |
| ponte | `status == tuning` |
| notifica | `_flying` |
| motore audio | `_muted` |

Il bug della notifica che spariva in volo (PR #9) era un disaccordo tra due di questi posti.

## Direzione

La sessione radio diventa uno stato Freezed sealed nel dominio, con una funzione pura per le transizioni **[C]**, approvata come direzione da Davide **[D]**.

```dart
@freezed
sealed class RadioSession with _$RadioSession {
  const factory RadioSession.off(Journey journey) = Off;
  const factory RadioSession.flying(Journey journey, {required FlightKind kind,
      required int attempt, required bool signalLost}) = Flying;
  const factory RadioSession.onAir(Journey journey, RadioStation station,
      {required OnAirPlayback playback, String? trackTitle}) = OnAir; // playing|paused|buffering
  const factory RadioSession.failed(Journey journey) = Failed;
}

// Journey: partenza, tratta, storico, viaggi, pila «indietro»: sopravvive a tutti gli stati.
RadioSession next(RadioSession session, RadioEvent event); // pura, nel dominio
```

**Domini e componenti:**
- **Dominio:** `RadioSession`, `Journey`, `RadioEvent` e `next()`, in Dart puro, senza Flutter né Riverpod.
- **Controller:** esegue soltanto gli effetti (fruscio, stream, notifica) e affida le decisioni a `next()`. Il token del volo resta solo per annullare le operazioni asincrone.
- **Una sola fonte per «in volo»:** `session is Flying`. La notifica non ha più un `_flying` con due scrittori, e il motore audio non lo deduce da `_muted`.
- **Schermata:** `RadioDisplay.of(session)` produce titolo, paese, etichetta e stato con uno `switch` esaustivo, testabile senza widget.
- **Dipendenze:** nessuna libreria nuova. Bastano i tipi sealed di Dart 3 e Freezed.

**Fuori dall'intervento:**
- preferiti e tema restano con `AsyncValue`; si estrae solo l'aiuto comune per il salvataggio con generazione, candidato per lo starter;
- animazioni e timer dei widget restano locali.

## Perché valorizza UX, DX e AX

**UX:**
- app e notifica leggono la stessa informazione e non possono contraddirsi;
- gli stati impossibili non si possono scrivere;
- il comportamento visibile resta identico: i test attuali restano verdi senza cambiare ciò che verificano.

**DX:**
- un nuovo stato fa segnalare dal compilatore ogni `switch` da aggiornare;
- le transizioni si testano come funzione pura, senza servizi finti né tempi;
- prepara la ricerca per paese (un nuovo tipo di volo) e le stazioni mute (un nuovo stato o evento).

**AX:**
- il comportamento della radio sta in un file leggibile dall'alto in basso, con la tabella delle transizioni accanto al tipo;
- meno flag sparsi da ricostruire;
- un test con un nome chiaro per ogni transizione.

## Costo e rischio

- **Tempo:** circa una giornata, in passi che lasciano l'app funzionante:
  1. `Journey`, `RadioSession` e `next()` con i loro test;
  2. il controller usa `next()`;
  3. una sola fonte per «in volo» in notifica e motore audio;
  4. `RadioDisplay` nella schermata.
- **Rischio:** medio. È il cuore asincrono dell'app. La suite esistente copre voli annullati, nuovi tentativi, pausa in volo e pila «indietro». Alla fine serve una revisione indipendente.

## Regola per lo starter **[C]**

- **Sealed Freezed:** un flusso con stati che hanno un significato proprio e transizioni guidate da eventi è un tipo sealed Freezed nel dominio, con transizioni pure. Il controller esegue solo gli effetti.
- **AsyncValue:** un valore letto o scritto in modo asincrono (caricamento, dati, errore) usa `AsyncValue` di Riverpod nel livello application.

## Decisioni del 15 novembre 2026

- **Sealed o `AsyncValue`:** a strati **[D]**.
  - Sealed Freezed nel dominio per i flussi con stati che hanno un nome nel prodotto e cambiano per eventi.
  - `AsyncValue` in application per i dati asincroni (caricamento, dati, errore).
  - Si combinano (`AsyncValue<RadioSession>`) se un flusso parte da un caricamento.
  - `AsyncValue` non sta nel dominio perché è un tipo di Riverpod.
- **Quando:** dopo la pubblicazione sul Play Store, prima della ricerca per paese **[D]**.
- **Fin dove:** sessione radio con notifica e schermata, più l'aiuto comune per il salvataggio di preferiti e tema **[D]**.
- **Starter prima:** la convenzione nasce nello starter, così le app nuove partono già con gli stati divisi bene; Frequenza si allinea con l'intervento **[D]**.

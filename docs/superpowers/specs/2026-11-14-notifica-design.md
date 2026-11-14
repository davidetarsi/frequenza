# Notifica stile Spotify — design

Data: 14 novembre 2026. Stato: da approvare da Davide.

Legenda: **[D]** = deciso da Davide; **[C]** = scelta proposta da Claude.

## Intento

Con la radio in tasca, la notifica (e la schermata di blocco) è il telecomando principale. Davide la vuole il più possibile simile a quella di Spotify **[D]**: logo di Frequenza, cambio stazione avanti e indietro, cuore per salvare tra i preferiti, oltre al play/pausa di oggi **[D]**.

Da Android 13 il riquadro dei media lo disegna il sistema, come per Spotify: l'app fornisce immagine, testi e tasti, la disposizione la decide Android.

## Obiettivi

1. **Tasti** **[D]**: indietro, play/pausa, avanti, cuore. Il tasto stop di oggi sparisce **[C]**, come in Spotify.
   - Sotto Android 13, nella notifica compatta: indietro, play/pausa, avanti **[C]**.
2. **Avanti** = girare la manopola: un volo verso una stazione a caso, con suono di sintonia, rotta e numero di viaggio, come nell'app **[C]**.
3. **Indietro, approccio A** **[D]**:
   - ogni pressione torna alla stazione precedente e la toglie dalla pila, come la cronologia del browser;
   - il ritorno è un volo come gli altri e conta come nuovo viaggio **[C]**;
   - «avanti» va sempre in un posto nuovo a caso, non rifà la strada;
   - la pila tiene **10 stazioni**, dura quanto la sessione;
   - quando la pila è vuota il tasto **resta** e riconnette la stazione in onda, come Spotify che riparte dall'inizio della canzone **[D]**, 14/11 dopo la revisione: Android 13+ altrimenti mette il cuore al posto di «indietro». La riconnessione non conta come viaggio e non cambia rotta né pila **[C]**.
4. **Cuore** **[D]**:
   - salva o toglie la stazione dai preferiti;
   - pieno se è salvata, vuoto se no;
   - sempre allineato a quello che succede nell'app, in tutti e due i sensi.
5. **Durante il volo** **[C]**:
   - la notifica mostra «In volo…» come oggi, senza avanti, indietro e cuore;
   - ricompaiono all'atterraggio.
6. **Immagini** **[D]** logo di Frequenza:
   - **icona piccola** nella barra di stato e in testa alla notifica: la manopola in bianco, generata da `tool/icon/generate.py` **[C]**. Oggi Android usa l'icona dell'app, che nella barra diventa una macchia;
   - **immagine grande**: il logo della stazione quando Radio Browser lo fornisce, altrimenti il logo di Frequenza **[C]**.
7. **Solo notifica** **[D]**: nell'app non compaiono tasti avanti e indietro, la manopola resta com'è.

## Non obiettivi

- Tasti avanti e indietro nell'app.
- Storico delle stazioni salvato tra una sessione e l'altra.
- Barra di avanzamento: è una diretta, non serve.
- Ricerca per paese o per nome, che verrà dopo la pubblicazione.

## Anti-obiettivi

- Un tasto della notifica che fa una cosa diversa da quella che mostra, o un cuore che dice «salvata» quando non lo è.
- Un comando dalla notifica che rompe un volo in corso o lascia l'app in uno stato diverso da quello mostrato.
- La notifica che sparisce o smette di rispondere con lo schermo spento.

## Approcci considerati, per il tasto indietro

- **A · Pila di stazioni, come il browser** (scelto **[D]**): si torna indietro di più tappe; costo minimo in più.
- **B · Solo la stazione precedente, come il canale precedente del telecomando**: più semplice, ma premendo due volte rimbalzi tra le ultime due.

## Vincoli

- Si costruisce su `audio_service` già in uso:
  - i tasti avanti e indietro sono `skipToNext` e `skipToPrevious`;
  - il cuore è un'azione personalizzata con icona Android.
- Nessuna nuova dipendenza Dart.
- La logica di avanti, indietro e cuore resta nel controller e nei provider. Il gestore della notifica riceve lo stato e inoltra i comandi, come oggi con play e pausa.
- Icone della notifica come vettori in `android/app/src/main/res/drawable`, bianche.
- `tool/check.sh` verde; test per la pila (avanti, indietro, limite 10, pila vuota), per i tasti mostrati in ogni stato e per il cuore nei due sensi.

## Lasciato al builder

- Come far arrivare a `audio_service` il logo di Frequenza come immagine grande, senza nuove dipendenze.
- Il disegno delle icone del cuore, pieno e vuoto.
- L'ordine dei tasti oltre il minimo richiesto: Android 13+ può comunque riordinarli.

## Limiti noti

- Sotto Android 13 il cuore non compare nella notifica: `audio_service` mette i tasti personalizzati solo nella sessione, che i telefoni vecchi non mostrano come tasti. Limite accettato **[D]**.

- Se il logo di una stazione è rotto, Android mostra la notifica senza immagine: l'app non lo sa in anticipo.
- La resa esatta va provata sul telefono: cambia tra le versioni di Android.

# Ritocchi dell'interfaccia — design

Data: 14 novembre 2026. Stato: da approvare da Davide.

Legenda: **[D]** = deciso da Davide; **[C]** = scelta proposta da Claude. Mockup: https://claude.ai/artifact/96zvDHwYk1p5hMXG3Kn9jU (proposta A, Impostazioni, Dettagli).

## Intento

Dopo la prima prova sul telefono l'app funziona e piace. Davide vuole una schermata principale più pulita e più ariosa: meno testo intorno alla radio, i comandi dentro la radio come tasti veri, impostazioni coerenti con i Preferiti. In più due piccole comodità: copiare il titolo della canzone e capire subito che l'orario è quello della stazione.

## Obiettivi

1. **Pausa e Salva dentro la radio** **[D]**, proposta A dei mockup:
   - una fila di due tasti a leva in un incavo, in fondo alla cassa, al posto della riga con viti e filo;
   - **senza scritte** **[D]**: icone pausa/play e cuore;
   - un tasto resta **abbassato** quando è attivo: in pausa (mostra play), oppure stazione già salvata (cuore pieno arancione) **[C]**;
   - disabilitati come oggi (nessuna stazione, sintonia in corso, errore) **[C]**: tasto opaco, non premibile;
   - etichette accessibili «Pausa», «Riprendi», «Salva», «Salvata»: oggi i bottoni hanno il testo, i tasti nuovi lo portano solo per TalkBack **[C]**;
   - spariscono i due bottoni sotto la radio.
2. **Preferiti in alto: solo il cuore** **[D]**:
   - bottone tondo con il bordo e il cuore di oggi;
   - un pallino con il numero dei preferiti, nascosto quando sono zero **[C]**;
   - il pallino ha **lo stesso colore del cuore e del suo bordo** **[D]**, con il numero nel colore di contrasto del tema **[C]**: è il colore primario del tema, generato da `#AD4823`, cioè lo stesso arancione della tacca della manopola e dell'icona. Nel tema scuro Material lo schiarisce perché si legga sul fondo scuro: per questo sembra un altro colore, ma è la stessa famiglia.
3. **Impostazioni come foglio dal basso, uguale a quello dei Preferiti** **[D]**:
   - stessa cornice: maniglia, titolo, sottotitolo, tasto chiudi, angoli, ombra;
   - sezioni Aspetto (Come il telefono, Chiaro, Scuro) e Lingua (Italiano, English), con le scelte di oggi;
   - la pagina `/settings` sparisce **[C]**.
4. **Radio un po' più piccola e più aria intorno** **[D]**:
   - larghezza della radio da 344 a 320 punti, mappa un po' più bassa **[C]**;
   - più spazio tra titolo e tasti in alto, «Prossima fermata», radio e crediti, come nel mockup **[C]**.
5. **Ora locale** **[D]**: la scritta «ORA LOCALE» piccola sopra l'orario, al posto dell'icona dell'orologio. In inglese «LOCAL TIME».
6. **Tenere premuto per copiare il titolo della canzone** **[D]**:
   - si copia solo il titolo trasmesso dalla stazione (il dato `trackTitle`), mai il nome della radio né le etichette mostrate quando il titolo manca **[D]**;
   - alla pressione una leggera vibrazione **[C]**;
   - da Android 13 il telefono mostra da sé la conferma della copia; sotto Android 13 l'app mostra «Titolo copiato» **[C]**.

## Non obiettivi

- Rifare palette o colori dell'app: il pallino usa il colore che c'è già.
- Copiare il nome della stazione (eventuale lavoro futuro).
- Cambiare come funzionano pausa, salvataggio, preferiti o impostazioni.

## Anti-obiettivi

- Un tasto che non dice da solo cosa fa, o il cui stato (giù/su) non corrisponde a ciò che succede.
- Testo che si taglia o radio che non entra nello schermo sui telefoni piccoli, con il testo grande o in orizzontale.
- Due avvisi di copia insieme su Android 13 e successivi.
- Perdere qualcosa per chi usa TalkBack: ogni tasto ha nome e stato.

## Approcci considerati

- **A · Tasti a leva sotto la radio** (scelto **[D]**): più grandi, si leggono da soli, il tasto abbassato mostra lo stato. Costa circa 60 punti di altezza, recuperati restringendo radio e mappa.
- **B · Tasti tondi tra altoparlante e manopola**: la radio non si allunga, ma i tasti sono piccoli, meno evidenti, e sui telefoni stretti lo spazio non basta.

## Vincoli

- Stesso stile di ora: palette `TravelRadioPalette`, misure in `RadioCabinetDesign` e `TravelRadioLayout`, niente valori sparsi nei widget.
- Funziona in tema chiaro e scuro, nelle tre disposizioni di oggi: normale, compatta (schermi bassi, testo grande) e orizzontale.
- Nessuna nuova dipendenza Dart **[C]**: la versione di Android per la conferma della copia arriva dal canale nativo che `MainActivity` ha già.
- `tool/check.sh` verde: test aggiornati per i tasti nuovi, il foglio delle impostazioni, il pallino e la copia.

## Lasciato al builder

- Disegno preciso dei tasti, cioè gradiente, ombra e profondità quando sono abbassati, purché leggano come nel mockup in tutti e due i temi.
- Dove vanno i tasti nella disposizione orizzontale e in quella compatta, purché restino dentro la radio e premibili (almeno 44 punti).
- Le spaziature esatte, in proporzione a quelle del mockup.
- Come condividere la cornice tra foglio dei Preferiti e foglio delle Impostazioni.

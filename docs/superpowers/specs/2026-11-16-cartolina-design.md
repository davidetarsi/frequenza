# Cartolina del luogo e canzoni salvate — design breve

Data: 16 novembre 2026. Stato: **da approvare** (salvataggio, segnalibro e schede approvati da Davide). Branch `docs/cartolina`, da `develop`.

Legenda:
- **[D]** decisione di Davide;
- **[C]** scelta di Claude.

## Intento

Ogni paese in cui si atterra lascia una cartolina: sul fronte il luogo, sul retro le canzoni che ci hai trovato. Davide vuole poter ritrovare una canzone per ascoltarla altrove, ma anche ricordare dove l'ha sentita **[D]**. L'idea nasce guardando Radio Paradise (slideshow di foto, cronologia dei brani), ripensata per un viaggio a caso tra le radio del mondo.

## Approcci

1. **Scelto: una cartolina per paese** **[D]**. Il paese c'è sempre ed è pulito; è anche l'unità del pescaggio e della futura scelta dei paesi.
2. **Scartato: una cartolina per città o regione.** Lo stato c'è in circa metà delle stazioni ed è scritto a mano, a volte in modi diversi per lo stesso posto («Sachsen» e «Saxony»; «SP» e «São Paulo (SP)»). Le coordinate ci sono in circa un quarto. Su un campione di 1.000 stazioni (16/11/2026): stato 49%, coordinate 26%.
3. **Scartato: le canzoni in un elenco separato.** Perde il legame con il luogo, che è metà del motivo per salvarle.

## Cosa si costruisce

**La cartolina**
- Una per paese, nel diario, come una collezione **[D]**.
- **Fronte:** foto del paese con autore e licenza, oppure, se la foto non c'è, la versione tipografica «saluti da» con il nome del paese.
- **Timbri delle regioni** (facoltativi): quando una stazione ha lo stato, sul fronte si aggiunge un piccolo timbro con quel nome. Se lo stato manca non si aggiunge niente **[C]**. Prima del confronto i nomi vengono puliti: spazi, maiuscole, accenti e parentesi finali. I doppioni in lingue diverse restano **[C]**.
- **Retro:** le canzoni salvate in quel paese, scritte a mano. Sotto ogni titolo, in piccolo, la stazione, la regione quando c'è, e la data **[D]**.

**Sulla radio**
- All'atterraggio lo schermo zooma sul paese e ne traccia la sagoma. La cartolina arriva da fuori, da destra, e si aggancia al bordo della radio. Al volo successivo si stacca **[D]**. Il movimento esatto si definisce con Davide quando si lavora all'animazione **[D]**: il mock-up attuale non lo convince.
- Toccando la cartolina si apre grande, e la si può girare per vedere il retro **[D]**.

**Le canzoni**
- **Il segnalibro accanto al titolo la salva** **[D]**. È una piccola icona dentro lo schermo, che compare solo quando c'è un titolo: vuota con il «+» (`bookmark_add_outlined`), piena con la spunta dopo il salvataggio (`bookmark_added`). Anche toccare il titolo salva. La canzone si scrive sul retro della cartolina del paese, con la stazione, la regione e la data.
- **L'avviso** compare in basso, fuori dalla radio, come la snackbar del sistema: «Salvata sulla cartolina degli Stati Uniti · Annulla» **[D]**.
- **Cuore e segnalibro non si confondono** **[D]**:
  - il cuore, tra i tasti della radio, è per la stazione: «preferite», «ci torno»;
  - il segnalibro, attaccato alla canzone, è per la canzone, che non si chiama mai «preferita»: «salvata sulla cartolina».
- **Scartati:**
  - la scheda dal basso con Salva, Cerca e Copia, perché era troppo un menu e copriva la radio **[D]**;
  - le icone dentro lo schermo, che portavano comunque tre scelte **[D]**;
  - un secondo cuore **[C]**;
  - la penna, che si legge come «modifica» **[D]**;
  - la puntina, che vuol dire «fissa in cima» **[C]**;
  - il «+» con le righe, troppo simile all'icona dei preferiti **[C]**.
- **Dove si ritrovano:** l'icona in alto apre un foglio con due schede, «Radio» e «Canzoni» **[D]**. Le canzoni sono raggruppate per paese, dalla più recente. Quando ci saranno le cartoline, ogni gruppo porterà al retro della sua cartolina **[C]**.
- **Una pressione lunga sul titolo** lo copia, come fa oggi il tocco **[C]**.
- Toccare di nuovo il titolo di una canzone già salvata non la duplica **[C]**.

**Il retro**
- **Sulla cartolina** piccola, agganciata alla radio, il retro non scorre: mostra le ultime 3 canzoni e «e altre N» **[C]**.
- **Aperto grande**, il retro diventa un elenco che scorre, dalla più recente, con il conteggio in alto («13 canzoni») **[D]**.
- **I tre puntini verticali** accanto a ogni canzone aprono un menu vicino alla riga, non una scheda dal basso **[D]**. Le voci sono:
  - Cerca su Spotify, Cerca su YouTube, Cerca su Apple Music;
  - Copia;
  - Riaccendi questa radio;
  - **Togli dalla cartolina**, per ultima e in rosso **[C]**.
- **Per togliere una canzone ci sono due strade** **[D]**:
  - trascinarla a sinistra: la riga viene cancellata a penna e sparisce;
  - la voce «Togli» del menu.
- In entrambi i casi compare «Tolta dalla cartolina · Annulla». Niente richiesta di conferma **[C]**.
- **Le ricerche** aprono direttamente l'app, con la ricerca già scritta; senza l'app si apre la stessa ricerca nel browser. Non si passa dalla clipboard **[C]**.
  - YouTube: `https://www.youtube.com/results?search_query=<q>`;
  - Spotify: `spotify:search:<q>`, oppure `https://open.spotify.com/search/<q>`;
  - Apple Music: `https://music.apple.com/search?term=<q>`.
- **Prima di costruire**, una prova sul telefono di Davide con una build di sviluppo dice quale link di Spotify funziona meglio e se Apple Music arriva sulla ricerca o solo sulla home **[C]**.
- **Solo i servizi installati:** il menu mostra solo le app presenti sul telefono, più «Cerca sul web». I tre pacchetti vanno dichiarati in `<queries>` nel manifest **[C]**.

## Dati

- **Sagome dei paesi:** dentro l'app, da Natural Earth semplificato (dominio pubblico), pochi KB per paese, così funzionano anche senza rete **[C]**.
- **Foto:** da Wikimedia Commons al momento dell'atterraggio, con autore e licenza salvati insieme al riferimento. Nel diario si salva solo il riferimento, non l'immagine **[C]**. La foto scelta per un paese resta la stessa, così la cartolina non cambia faccia a ogni visita **[C]**.
- **Privacy:** le canzoni salvate restano sul telefono, come tutto il diario. La richiesta a Wikimedia rivela solo il paese di cui serve la foto, senza dati della persona. Va comunque detto nell'informativa sulla privacy, e la sezione dello Store sulla sicurezza dei dati va ricontrollata **[C]**.

## Ordine dei lavori

1. **Pulizia del titolo:** togliere le scritte tipo «Now On Air:» e la pubblicità, e separare artista e titolo dove c'è « - ».
2. **Prova dei link di ricerca** sul telefono. Poi **salvare una canzone** con il segnalibro, e l'elenco delle canzoni salvate con menu, trascinamento e «Annulla». Finché le cartoline e il diario non ci sono, l'elenco sta nella scheda «Canzoni» dei preferiti; poi passa sul retro delle cartoline.
3. **Sagoma del paese e cartolina tipografica** agganciata alla radio.
4. **Diario:** il registro (parte 1, piano già scritto) e la collezione delle cartoline con il retro.
5. **Foto da Wikimedia Commons** e informativa aggiornata.

Ogni passo ha il suo piano.

## Fuori, per dopo

- **La cassetta del viaggio:** le canzoni salvate in ordine di viaggio, condivise come immagine con la rotta.
- **«L'ultima volta qui suonava…»:** richiede la cronologia automatica del diario.
- **«Sentita anche in Brasile»:** la stessa canzone ritrovata in due paesi.
- **Cronologia automatica** di tutti i titoli passati: arriva con il diario, se servirà.

## Lasciato a chi costruisce

- Il tratto della scrittura a mano: il font e quanto è leggibile.
- Il numero massimo di timbri visibili sul fronte.
- Come scorre un retro molto pieno.

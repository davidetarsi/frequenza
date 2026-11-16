# Cartolina del luogo e canzoni salvate — design breve

Data: 16 novembre 2026. Stato: **da approvare**. Branch `docs/cartolina`, da `develop`.

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
- Il gesto c'è già: toccando il titolo sullo schermo, oggi si copia. Ora si apre una piccola scheda con tre voci: **Salva**, **Cerca su…** e **Copia** **[C]**. Niente secondo cuore, per non ricreare la confusione appena risolta **[C]**.
- **Salva** scrive la canzone sul retro della cartolina del paese, con la stazione, la regione e la data.
- **Cerca su…** apre la ricerca nel browser o nell'app, senza account né collegamenti **[C]**:
  - Spotify: `https://open.spotify.com/search/<q>`;
  - YouTube: `https://www.youtube.com/results?search_query=<q>`;
  - Apple Music: `https://music.apple.com/search?term=<q>`.
- Dal retro di una cartolina, ogni canzone offre di nuovo **Cerca su…** e **Riaccendi questa radio** **[C]**.

## Dati

- **Sagome dei paesi:** dentro l'app, da Natural Earth semplificato (dominio pubblico), pochi KB per paese, così funzionano anche senza rete **[C]**.
- **Foto:** da Wikimedia Commons al momento dell'atterraggio, con autore e licenza salvati insieme al riferimento. Nel diario si salva solo il riferimento, non l'immagine **[C]**. La foto scelta per un paese resta la stessa, così la cartolina non cambia faccia a ogni visita **[C]**.
- **Privacy:** le canzoni salvate restano sul telefono, come tutto il diario. La richiesta a Wikimedia rivela solo il paese di cui serve la foto, senza dati della persona. Va comunque detto nell'informativa sulla privacy, e la sezione dello Store sulla sicurezza dei dati va ricontrollata **[C]**.

## Ordine dei lavori

1. **Pulizia del titolo:** togliere le scritte tipo «Now On Air:» e la pubblicità, e separare artista e titolo dove c'è « - ».
2. **Scheda del titolo:** Salva, Cerca su…, Copia. Finché il diario non c'è, le canzoni salvate restano in un elenco semplice, che poi passa sulle cartoline.
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

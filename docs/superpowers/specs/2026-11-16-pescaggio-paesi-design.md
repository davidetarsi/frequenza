# Pescaggio per paese — design breve

Data: 16 novembre 2026. Stato: **approvato da Davide**. Branch `feat/pescaggio-paesi`, da `develop`.

Legenda:
- **[D]** decisione di Davide;
- **[C]** scelta di Claude.

## Intento

Oggi la manopola pesca a caso tra tutte le stazioni di Radio Browser, quindi un paese esce in proporzione alle sue stazioni. Stati Uniti e Germania valgono da soli circa un giro su quattro, e 61 paesi con 5 stazioni o meno non escono quasi mai. In più il server tiene in cache la risposta «casuale» per circa 10 minuti: in quel tempo ogni giro pesca dalle stesse 30 stazioni. Infine due mirror su tre (`nl1`, `at1`) non esistono più.

Davide vuole un viaggio più vario, e in futuro vuole far scegliere all'utente un paese o un gruppo di paesi. Il pescaggio di oggi va costruito già nella forma che servirà allora **[D]**.

## Approcci

1. **Scelto: prima il paese, pesato con la radice quadrata delle sue stazioni, poi una stazione di quel paese** **[D]**. Gli Stati Uniti passano dal 13,5% a circa il 4,5%; i paesi piccoli salgono senza dominare.
2. **Scartato: com'è oggi**, in proporzione alle stazioni. È sbilanciato e non porta alla scelta per paese.
3. **Scartato: paese a caso, tutti uguali.** Escono troppo spesso paesi con 1–2 stazioni, spesso mute.

## Cosa si costruisce

- **`CountryDraw`** (dominio, funzione pura): da un elenco `codice → numero di stazioni` estrae un paese con peso `sqrt(n)`.
  - `among`: insieme facoltativo dei paesi ammessi. Vuoto o assente vale tutto il mondo. Domani sarà il paese scelto (un gruppo di uno) o un gruppo dell'utente **[D]**.
  - `skip`: paesi da non estrarre, cioè quelli risultati vuoti in questa sessione.
  - Paesi con 0 stazioni non escono mai. Se non resta nessun paese, restituisce `null`.
- **Elenco dei paesi:** `/json/countries`, chiesto una volta e tenuto in memoria dal repository per tutta la sessione. Se fallisce, si riprova al giro successivo **[C]**.
- **`RadioRepository.getRandomStation({Set<String>? countries, Set<String> avoid = const {}})`** al posto di `countryCode`, che oggi nessuno usa:
  1. estrae un paese;
  2. chiede 30 stazioni a caso di quel paese (`hidebroken`, `order=random`) con un parametro `seed` che cambia a ogni richiesta, per saltare la cache del server;
  3. tiene quelle in HTTPS, toglie quelle in `avoid` e ne sceglie una;
  4. se non resta niente, segna il paese come vuoto per la sessione e ne estrae un altro, fino a **4 paesi** **[C]**;
  5. senza elenco dei paesi, oppure con `countries` assente e 4 paesi a vuoto, pesca su tutto il mondo come oggi (sempre con `seed` e `avoid`), così la manopola non resta mai muta **[C]**.
- **Ripetizioni:** `RadioController.tuneRandom` passa come `avoid` gli id di `journey.previous` e `journey.landed`, cioè le ultime 10 stazioni lasciate più quella in onda **[C]**. Non serve stato nuovo.
- **Server:** `https://all.api.radio-browser.info` (il nome che Radio Browser mantiene aggiornato), poi `https://de1.api.radio-browser.info` come riserva **[C]**.

## Fuori

- Interfaccia per scegliere un paese o creare gruppi: lavoro successivo, che userà `countries` senza cambiare questa parte.
- Pesare i paesi sulle sole stazioni in HTTPS: `/json/countries` conta tutte le stazioni, la differenza è piccola e i paesi a vuoto sono già gestiti.

# Principi di Frequenza

Una pagina per misurare ogni idea nuova con la stessa regola. Scritta il 17 novembre 2026, dopo una discussione tra Davide e Claude sulle canzoni salvate e sul login.

## L'idea

Tocchi, voli, atterri in un posto a caso del mondo e senti che radio c'è. Tutto il resto è il ricordo del viaggio, non una funzione in più.

## Tre domande per ogni aggiunta

1. **Chi apre l'app per la prima volta arriva al suono con un tocco?** Niente registrazioni, scelte o spiegazioni prima della prima radio.
2. **La schermata della radio resta la radio?** Le aggiunte stanno nei fogli che si aprono solo se li cerchi. Sullo schermo principale entra solo ciò che si può ignorare senza perdere niente.
3. **Succede da sola o chiede qualcosa?** Meglio ciò che accade mentre viaggi, come il diario che si scrive da sé, di ciò che chiede un gesto o una decisione. Quando serve un gesto, ne basta uno, e si può annullare.

Se un'idea non passa una delle tre domande, si ripensa o si lascia fuori.

## Scelte che ne derivano

- **Niente account.** Preferiti, canzoni e diario restano sul telefono. Il login porterebbe attrito alla prima apertura, un server, password, dati personali e la cancellazione dell'account richiesta dal Play Store. Serve solo per cose che oggi non ci sono: lo stesso diario su più telefoni, o qualcosa di sociale tra utenti.
- **Statistiche anonime, che si spengono** (decisione di Davide del 17/11/2026): nessun identificativo, nessun dato su chi sei, mai una domanda prima della prima radio. Sostituisce il «nessun dato raccolto» di prima.
- **Il cambio di telefono si risolve senza login:** con il backup automatico di Android (`allowBackup`) e, se servirà, un «esporta / importa» in un file.
- **Niente pubblicità e niente algoritmo** che decide cosa ti piace, come dice il README.
- **Ogni integrazione esterna ha una necessità concreta** ed è una feature a sé, con il contratto nel domain (regola di AGENTS.md).

## Esempi

- **Canzoni salvate: sì.** Il segnalibro compare solo se c'è un titolo, si usa con un tocco e si annulla. L'elenco sta nel foglio dei preferiti.
- **Cartolina agganciata alla radio: da tenere d'occhio.** Tocca la schermata principale a ogni atterraggio. Deve restare leggera e facile da ignorare.
- **Login: no**, per i motivi sopra.

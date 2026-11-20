# Frequenza — istruzioni persistenti

## Metodo di lavoro

Applicare questo metodo in tutte le sessioni relative al progetto:

1. Pianificare solo la fase corrente: un piano breve con file coinvolti, decisioni essenziali e criteri di completamento. Usare la roadmap generale come riferimento, senza anticipare piani dettagliati delle fasi successive.
2. Implementare direttamente nella stessa sessione, riutilizzando componenti e convenzioni già verificati. Procedere nelle scelte tecniche ordinarie già autorizzate; coinvolgere Davide per direzione visiva e cambiamenti sostanziali.
3. Eseguire controlli mirati: analisi statica, test del comportamento significativo e build quando pertinente. Evitare test che duplicano banalmente l'implementazione e verifiche ripetute senza cambiamenti o nuovi dubbi.
4. Aggiornare sinteticamente lo stato della roadmap: risultati verificati, problemi aperti e prossimo passo. Lasciare un punto di ripresa persistente per le sessioni successive.

Obiettivo: contenere token, tempo e lavoro duplicato senza sacrificare correttezza, sicurezza o qualità. Un agente principale; revisioni indipendenti solo nei passaggi delicati. Comunicazione sintetica, nessuna documentazione duplicata.

## Convenzioni del template

- Feature-first; contratti Dart indipendenti da Flutter e Riverpod, wiring in application.
- Modelli e stati strutturati con Freezed, serializzazione generata per i dati JSON e provider Riverpod annotati. Rigenerare e versionare i sorgenti prodotti da build_runner.
- Stati a strati: un flusso con stati che hanno un nome nel prodotto e cambiano per eventi è un tipo sealed Freezed nel dominio, con transizioni pure (`next(stato, evento)`) e la tabella delle transizioni accanto; il controller esegue solo gli effetti. Un valore letto o salvato in modo asincrono usa `AsyncValue` nel livello application. Esempio: `features/radio/domain/radio_session.dart`.
- Usare e mantenere i componenti e i token comuni in lib/ui. Tenere i controlli specifici del prodotto nelle feature.
- Leggere docs/status.md per il punto di ripresa, poi solo il piano attivo.
- Non aggiungere integrazioni esterne senza necessità concreta. Ognuna è una feature: il contratto nel domain, senza Flutter né Riverpod; il servizio esterno nel data.
- Non commettere segreti, chiavi di firma o percorsi locali di SDK.

## Regole vincolanti per il lavoro dell'assistente

Queste regole guidano il lavoro locale dell'assistente. Non introdurre nuovi
vincoli automatici in CI, branch protection o PR per farle rispettare: Davide ha
esplicitamente escluso questo approccio il 19 novembre 2026.

- Prima di modificare una feature, leggere i suoi contratti, stati, componenti e
  token esistenti. Riutilizzarli prima di creare nuove astrazioni o widget.
- Domain: Dart puro, senza Flutter, Riverpod, plugin o import da data/application/
  presentation. Modelli e stati strutturati del prodotto con Freezed. I flussi
  del prodotto hanno stati nominati, eventi e transizioni pure documentate.
- Application: provider Riverpod annotati e controller che orchestrano gli
  effetti. AsyncValue per letture/salvataggi asincroni. Le mutazioni concorrenti
  devono preservare tutti i dati e gestire risultati obsoleti ed errori.
- Data: implementazioni dei repository/gateway. Accessi a preferenze, database,
  rete e plugin passano da contratti iniettati. I dettagli della piattaforma
  non devono essere raggiunti direttamente dai widget.
- Presentation: mostra lo stato e invia intenzioni. Controller di animazioni,
  coordinate e dettagli effimeri dei gesti restano qui, senza decidere lo stato
  del prodotto o introdurre logica di persistenza.
- UI: palette, tipografia, pesi, dimensioni, spaziature, raggi, opacità e tempi
  grafici appartengono a lib/ui/theme. Nei widget usare token/stili semantici.
  Costanti matematiche, dati esterni e codici tecnici non sono token grafici.
- Copy applicativo e testi di accessibilità nel dizionario IT/EN, con
  segnaposto coerenti. Dati esterni e nomi propri non si traducono arbitrariamente.
  La lingua scelta nell'app deve essere usata coerentemente dalle sue superfici.
- Sicurezza prima: validare gli ingressi, minimizzare i dati, non esporre segreti,
  mantenere firma e configurazioni prod corrette. Non cambiare scelte di prodotto
  come backup, consenso o fornitori per una propria preferenza tecnica.
- Prima di dichiarare concluso un intervento, confrontare il diff con queste
  regole, eseguire controlli proporzionati e registrare risultati e limiti.
  Non correggere le deviazioni esistenti con refactor indiscriminati fuori fase.

### Deroghe

Se una soluzione richiede una deroga, fermare solo la parte dipendente e chiedere
approvazione a Davide spiegando la regola interessata, il caso concreto, le
alternative e la conseguenza della deroga. Il silenzio non è approvazione.
Non usare annotazioni, commenti, allowlist o debito preesistente come autorizzazione.
Una deroga approvata va registrata in docs/deroghe.md con data, ambito preciso,
motivazione, approvazione e condizioni di riesame. Non generalizzarla ad altri casi.
Le regole valgono anche per il codice scritto di recente dall'assistente.

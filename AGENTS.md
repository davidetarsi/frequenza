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
- Usare e mantenere i componenti e i token comuni in lib/ui. Tenere i controlli specifici del prodotto nelle feature.
- Leggere docs/status.md per il punto di ripresa, poi solo il piano attivo.
- Non aggiungere integrazioni esterne senza necessità concreta.
- Non commettere segreti, chiavi di firma o percorsi locali di SDK.

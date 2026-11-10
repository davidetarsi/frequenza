# Fase 3 — integrazione radio da viaggio

Spec: mockup approvato in conversazione, work/visualizations/frequenza-radio-da-viaggio.html nel progetto padre.
Metodo: implementazione nella stessa sessione; animazioni avanzate esplicitamente rinviate.

1. Preferiti: contratto Dart che carica/salva RadioStation, adattatore SharedPreferences, controller con caricamento/salvataggio serializzati e gestione errori. Test: riapertura archivio, toggle per ID, scrittura fallita senza perdita dati.
2. UI: RadioPage come home, RadioCabinet con display/stato, manopola come azione primaria, Pausa/Riprendi e Salva/Salvata; pannello dal basso con vuoto/caricamento/errore/elenco, rimozione e ascolto. Nessuna nuova chiamata di rete prima dell'azione utente. Localizzazione IT/EN; nessun log tecnico nella home. La pagina di prova resta disponibile nel codice.
3. Verifiche: test integrazione su nuova home, preferiti, riproduzione da pannello, testo 200% su 320px; analyzer, formattazione, bundle; tentativo suite Flutter una volta per il codice nuovo. Documentare eventuali limiti di socket e APK senza riprovare inutilmente.

File: lib/features/favorites/{domain,data,application,presentation}, lib/features/radio/presentation/{radio_page,radio_cabinet}.dart, lib/app/app.dart, lib/l10n/app_{it,en}.arb, pubspec, test/app_test.dart e test/features/favorites/.

Interfacce: FavoritesRepository.load(): Future<List<RadioStation>>; save(List<RadioStation>): Future<void>. FavoritesController.load()/toggle(RadioStation): Future<void>; stato con stations, isLoading, isSaving, hasError. favoritesProvider è il punto di override nei test. RadioPage riusa radioControllerProvider e tuneTo per i preferiti.

Rischi da verificare: scrittura persistente fallita, caricamento iniziale ancora pendente, titolo lungo/testo grande, sheet con molti elementi, nessuna autoplay all'avvio. Conservare in docs/status.md i limiti preesistenti della prova Android e della concorrenza del player.

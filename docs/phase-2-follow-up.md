# Fase 2 — verifica di ripresa

Perimetro: chiudere i problemi osservati nella prova tecnica esistente prima della UI definitiva. Nessuna ricostruzione del template e nessun piano dettagliato delle fasi successive.

1. Stato: il copyWith usa `errorMessage ?? this.errorMessage`; il tentativo di pulire l'errore passando null non funziona. Aggiungere un comando esplicito di pulizia e una regressione Dart eseguibile senza socket.
2. Audio: verificare il contratto di just_audio.play, che termina alla fine/interruzione della riproduzione; la sintonizzazione di uno stream live non deve attendere quella fine. Annullare le subscription alla chiusura e catturare gli errori asincroni.
3. Verificare formattazione, analisi e compilazione. Tentare i test della nuova app una volta; se la sandbox vieta socket, registrare il limite senza riprovare a vuoto.
4. Aggiornare report e punto di ripresa: una risposta HTTP non certifica decodifica audio, redirect HTTPS del player nativo o background su dispositivo. Queste prove restano aperte.

La fase 3 richiederà un mockup da sottoporre a Davide prima della UI definitiva e delle animazioni. Non dichiarare la fase 2 chiusa finché mancano le verifiche Android previste.

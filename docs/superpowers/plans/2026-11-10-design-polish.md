# Resa radio e preferiti

Richiesta: migliorare la resa della radio da viaggio già approvata e dare identità al bottom sheet. Interrompere la ricerca audio; animazioni avanzate restano rinviate.

- Palette prodotto centralizzata in ui/theme/travel_radio_palette.dart, condivisa da radio e preferiti. Nessuna modifica al template generico.
- Cabinet: scocca con profondità e cornice, maniglia aperta, display incassato, griglia stratificata, manopola metallica con indice e tacche decorative. Manopola resta unico comando primario.
- Sheet: route Material per accessibilità e dismiss, contenuto custom coordinato (avorio/petrolio, header, card stazione, Paese, stato ascolto, rimozione), vuoto/errori/scroll conservati.
- Verifiche: suite esistente più rimozione dal pannello ed errore/retry; testo al 200%, tema scuro. Analyzer e bundle. Esaminare una cattura Flutter di home e sheet se possibile.
- Template: dipendenze per feature e contratto Dart corretti; providers manuali e interfaccia audio in application usata da data sono scostamenti preesistenti da uniformare in un intervento tecnico dedicato, non dentro il restyling.

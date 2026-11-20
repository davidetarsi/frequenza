# Immagini della pagina di anteprima

`capture_test.dart` esporta le pagine reali dell'app in `docs/img` a 780×1688,
con UI italiana e inglese, tema scuro e riproduzione simulata. Usa i repository
in memoria già presenti nei test: nessuna connessione audio o analytics.
Il diario contiene sei ascolti dimostrativi per 148 minuti e viene scorso
leggermente per mostrare anche la lista sotto la mappa.

Dalla radice del repository, con il Flutter previsto da `pubspec.yaml`:

```sh
flutter test tool/preview/capture_test.dart
CHROME_BIN=/percorso/del/browser/chrome node tool/preview/render_site.cjs
```

Il primo comando carica i font Android dal Flutter SDK (`FLUTTER_ROOT`,
impostato da `flutter test`), senza usare i glifi Ahem dei test. Il generatore
è esplicito, fuori da `test/`, e non riscrive le immagini durante la suite CI.

Il secondo comando richiede Node 22+ e Chromium/Chrome. Renderizza
`social.html` in `docs/img/anteprima-radio-diario.png` (1200×630), poi verifica
la pagina a 390 e 1280 px in IT/EN e con tema chiaro/scuro: due immagini
visibili, nessuna immagine mancante e nessuno scorrimento orizzontale.
Le anteprime della pagina finiscono nella directory temporanea di sistema.
Le schermate mostrano i widget Flutter, senza le barre del sistema operativo.

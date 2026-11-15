# Pagina di benvenuto — design breve

Data: 15 novembre 2026. Stato: **approvato da Davide**. Branch `feat/benvenuto`, costruito sopra `docs/readme`.

Legenda:
- **[D]** decisione di Davide;
- **[C]** scelta di Claude.

## Intento

Chi apre l'app per la prima volta deve capire in pochi secondi cosa fa: si gira la manopola e si atterra su una radio in diretta, da qualche parte nel mondo. I tasti sono pochi, quindi un'animazione basta a spiegare tutto **[D]**.

## Approcci

1. **Scelto: animazione nell'app** **[D]**. È leggera, segue i colori e il tema, e cambia lingua all'istante.
2. **Scartato: un video registrato.** Pesa 1–2 MB per lingua, non segue il tema e va rifatto a ogni ritocco grafico.
3. **Scartato: schede scorrevoli con gli screenshot.** Hanno troppo l'aria di un tutorial.

## Cosa si vede

- **Quando:** solo alla prima apertura, poi mai più **[D]**.
- **In alto:** le targhette **EN · IT**, le stesse `CodeBadge` delle Impostazioni **[D]**. Toccandone una, tutta l'app e la pagina cambiano lingua subito.
  - **Preselezionata** è la lingua con cui l'app si apre già: l'italiano su un telefono in italiano, l'inglese su tutti gli altri **[C]**. Su un telefono non italiano è l'inglese che Davide ha chiesto; su uno italiano evita di partire in inglese per chi parla italiano.
- **Al centro: l'animazione**, la radio vera (`RadioCabinet`) guidata da un copione in loop di circa 6 secondi **[D]**:
  1. spenta, «Dove andiamo?»;
  2. la manopola gira e la radio va in volo: schermo «In volo verso…» e mappa in volo;
  3. atterraggio su una stazione inventata, con paese, distanza e rotta disegnata sulla mappa;
  4. una pausa sulla stazione, poi di nuovo da capo.
- **Animazione muta** **[D]**: niente fruscio all'avvio.
- **Riduzione del movimento attiva:** un'immagine ferma, quella della stazione atterrata **[D]**.
- **Sotto:** il titolo «Turn the dial. Land somewhere in the world.» e una riga di spiegazione, tradotti **[D]**.
- **Pulsante «Turn it on»** (it: «Accendi la radio»): segna la pagina come vista e porta alla radio, spenta e pronta **[D]**.

## Come **[C]**

- **Feature:** `lib/features/welcome/`.
  - `WelcomeSeen` è un `@Riverpod(keepAlive: true)` asincrono. Legge e salva in `shared_preferences` la chiave `app.welcomeSeen` con `LatestSave`, come `AppThemeMode`.
  - La pagina è `WelcomePage` e l'animazione è `WelcomeDemo`.
- **Router:** una route `/welcome`. Finché `WelcomeSeen` vale falso, `/` rimanda lì. Il valore si legge in `bootstrap` prima di `runApp`, così la prima schermata è già quella giusta.
- **La manopola gira:** `RadioCabinet` riceve un `dialTurns` facoltativo, cioè la rotazione della manopola in giri. Vale 0 nell'uso normale.
- **Il demo** non tocca audio, controller né preferiti. Un `AnimationController` sceglie la scena, e ogni scena costruisce `RadioCabinet` e `RouteMap` con dati fissi. Tutto è ignorato dai tocchi e annunciato ai lettori di schermo con una sola etichetta.

## Fuori

- Rivedere la pagina dalle Impostazioni.
- Il suono.
- Più pagine.

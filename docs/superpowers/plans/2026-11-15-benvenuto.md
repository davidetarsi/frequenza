# Pagina di benvenuto — piano di implementazione

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** alla prima apertura una pagina mostra la radio che vola e atterra, permette di scegliere EN/IT e porta alla radio.

**Architecture:**
- un provider persistente `WelcomeSeen`;
- una route `/welcome` con redirect da `/`;
- una `WelcomePage` che anima la `RadioCabinet` vera con un copione fisso.

**Tech Stack:** Flutter, Riverpod (annotazioni), go_router, easy_localization, shared_preferences.

**Spec:** `docs/superpowers/specs/2026-11-15-benvenuto-design.md`

## Global Constraints

- **Chiave delle preferenze:** `app.welcomeSeen`.
- **Testi:**
  - en: «Turn the dial.\nLand somewhere in the world.», «Every turn is a live station from another corner of the planet. Keep the ones you love with the heart.», «Turn it on»;
  - it: «Gira la manopola.\nAtterri da qualche parte nel mondo.», «Ogni giro è una radio in diretta da un altro angolo del pianeta. Quelle che ami le tieni con il cuore.», «Accendi la radio».
- **Etichetta per i lettori di schermo:**
  - en: «Animation: the dial turns and the radio lands on a station far away»;
  - it: «Animazione: la manopola gira e la radio atterra su una stazione lontana».
- **Animazione:** muta e in loop di 6 s. Con la riduzione del movimento è ferma sulla stazione atterrata.
- **Verifica di fine task:** `bash tool/check.sh`; per l'ultimo task `--apk`.

## Review Focus

1. **Seconda apertura:** la radio, mai il benvenuto (Task 1).
2. **Salvataggio fallito:** il pulsante porta comunque alla radio e non resta bloccato (Task 1).
3. **Lingua cambiata dal benvenuto:** resta anche nella radio e alle aperture successive (Task 2).
4. **Riduzione del movimento:** nessun timer gira, quindi `pumpAndSettle` termina (Task 2).
5. **Schermi piccoli e testo grande:** niente overflow a 320×568 con testo al 130% (Task 2).

---

### Task 1: Stato «visto» e instradamento

**Files:**
- Create: `lib/features/welcome/application/welcome_seen.dart`
- Modify: `lib/app/routing/app_router.dart`, `lib/app/bootstrap.dart`
- Test: `test/features/welcome/welcome_flow_test.dart`

**Interfaces:**
- `@Riverpod(keepAlive: true) class WelcomeSeen`:
  - `Future<bool> build()`;
  - `Future<void> markSeen()`, che mostra subito `true` anche se il salvataggio fallisce.
- `AppRoutes.welcome = '/welcome'`. Un redirect porta su `/welcome` quando `WelcomeSeen` vale `false`.

- [ ] **Step 1:** test «a first launch opens the welcome, then the radio stays» (preferenze vuote: si vede «Turn it on»; un tocco porta alla radio e la preferenza diventa `true`) e «a later launch opens the radio» (preferenza `true`: niente benvenuto).
- [ ] **Step 2:** eseguirli. Expected: FAIL.
- [ ] **Step 3:** implementare, con una pagina provvisoria che ha solo il pulsante.
- [ ] **Step 4:** `bash tool/check.sh`. Expected: verde, anche i test esistenti, che partono con il benvenuto già visto.
- [ ] **Step 5:** commit `feat(benvenuto): alla prima apertura la pagina di benvenuto, poi la radio`.

### Task 2: La pagina e l'animazione

**Files:**
- Create: `lib/features/welcome/presentation/welcome_page.dart`, `welcome_demo.dart`
- Modify: `lib/features/radio/presentation/radio_cabinet.dart` (`dialTurns`), `assets/translations/*.json` (rigenerare con `tool/generate_l10n.sh`)
- Test: `test/features/welcome/welcome_page_test.dart`

**Interfaces:**
- `RadioCabinet({double dialTurns = 0})`: la manopola ruota di `dialTurns` giri.
- `WelcomeDemo` è uno `StatefulWidget` con un `AnimationController` di 6 s in loop. La scena dipende dal valore:
  - `< 1/6`: spenta;
  - `< 1/2`: in volo, con la manopola che gira di un giro;
  - altrimenti: atterrata su «Radio Paraíso», Brasile, partendo dal centro dell'Italia.

- [ ] **Step 1:** test:
  - «the demo flies and lands»: a 0 s c'è il testo spento, a 2 s «In volo verso…» o il suo equivalente, a 4 s «Radio Paraíso»;
  - «choosing IT switches the page to Italian»;
  - «with reduced motion the demo rests on the landed station» (`pumpAndSettle` termina e si vede «Radio Paraíso»);
  - «fits a small screen with large text».
- [ ] **Step 2:** eseguirli. Expected: FAIL.
- [ ] **Step 3:** implementare `dialTurns`, la demo, la pagina e i testi.
- [ ] **Step 4:** `bash tool/check.sh --apk`. Expected: verde e APK costruita.
- [ ] **Step 5:** `docs/status.md`, sezione «Pagina di benvenuto — 15 novembre 2026», con le prove da fare sul telefono. Commit `feat(benvenuto): la radio gira la manopola e atterra, con la scelta della lingua`.

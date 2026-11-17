# Pescaggio per paese — piano di implementazione

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** la manopola estrae prima un paese, pesato con la radice delle sue stazioni, poi una stazione nuova di quel paese.

**Architecture:** una funzione pura `CountryDraw` nel dominio; il repository Radio Browser tiene l'elenco dei paesi, estrae e chiede le stazioni con un `seed`; il controller passa le stazioni da evitare.

**Tech Stack:** Flutter, Riverpod, http (`MockClient` nei test).

**Spec:** `docs/superpowers/specs/2026-11-16-pescaggio-paesi-design.md`

## Global Constraints

- Peso del paese: `sqrt(stationcount)`; 0 stazioni non esce mai.
- Stazioni chieste per paese: 30, `hidebroken=true`, `order=random`, più `seed` diverso a ogni richiesta.
- Paesi tentati per giro: 4, poi pescaggio su tutto il mondo (solo se `countries` è assente).
- Server: `https://all.api.radio-browser.info`, poi `https://de1.api.radio-browser.info`.
- Verifica di fine task: `bash tool/check.sh`.

## Review Focus

1. **Elenco dei paesi che non arriva:** la manopola trova comunque una stazione (Task 2).
2. **Tutte le stazioni del paese già ascoltate o in HTTP:** si passa a un altro paese, senza ripetere (Task 2).
3. **`countries` con un solo paese vuoto:** restituisce `null`, non una stazione di un altro paese (Task 2).
4. **Elenco con codici minuscoli o vuoti:** ignorati o normalizzati, senza eccezioni (Task 1).
5. **Due giri di fila:** due richieste con `seed` diversi (Task 2).

---

### Task 1: `CountryDraw`

**Files:**
- Create: `lib/features/radio/domain/country_draw.dart`
- Test: `test/features/radio/country_draw_test.dart`

**Interfaces:**
- Produces: `abstract final class CountryDraw { static String? pick(Map<String, int> stations, {Set<String>? among, Set<String> skip = const {}, Random? random}); static double weight(int stations); }`

- [ ] **Step 1:** test:
  - «weights a country by the square root of its stations» (`weight(100) == 10`, `weight(0) == 0`);
  - «a country with four times the stations comes up twice as often» (10.000 estrazioni con `Random(1)`, rapporto tra 1,8 e 2,2);
  - «draws only among the chosen countries»; «never draws a skipped or empty country»;
  - «returns null when nothing is left»; «codes are compared in upper case».
- [ ] **Step 2:** eseguirli. Expected: FAIL (file mancante).
- [ ] **Step 3:** implementare.
- [ ] **Step 4:** `bash tool/check.sh`. Expected: verde.
- [ ] **Step 5:** commit `feat(radio): estrazione del paese pesata con la radice delle sue stazioni`.

### Task 2: Repository e controller

**Files:**
- Modify: `lib/features/radio/domain/radio_repository.dart`, `lib/features/radio/data/radio_browser_repository.dart`, `lib/features/radio/application/radio_controller.dart`, `test/features/radio/radio_controller_test.dart` (il finto repository)
- Test: `test/features/radio/radio_browser_repository_test.dart`, `radio_controller_test.dart`

**Interfaces:**
- Consumes: `CountryDraw.pick`.
- Produces: `Future<RadioStation?> getRandomStation({Set<String>? countries, Set<String> avoid = const {}})`; `RadioController.tuneRandom({Set<String>? countries})`.

- [ ] **Step 1:** test del repository, con `MockClient` che risponde a `/json/countries` e `/json/stations/search`:
  - «asks for stations of the drawn country, with a fresh seed each time»;
  - «loads the countries once per session»;
  - «skips stations to avoid and HTTP streams»;
  - «moves to another country when one has nothing, and remembers it»;
  - «falls back to the whole world when the countries do not load»;
  - «with chosen countries it never leaves them» (un solo paese vuoto → `null`);
  - «uses all.api first, then de1».
  Test del controller: «tuning avoids the stations just heard» (il finto repository registra `avoid`).
- [ ] **Step 2:** eseguirli. Expected: FAIL.
- [ ] **Step 3:** implementare.
- [ ] **Step 4:** `bash tool/check.sh`. Expected: verde.
- [ ] **Step 5:** commit `feat(radio): prima il paese, poi una stazione nuova di quel paese`.

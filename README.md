<p align="center">
  <img src="fastlane/metadata/android/en-US/images/icon.png" width="96" alt="Frequenza icon">
</p>

<h1 align="center">Frequenza</h1>

<p align="center">
  <em>A travel radio. Turn the dial, land somewhere in the world.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Riverpod-1F2A44?style=for-the-badge&logo=dart&logoColor=white" alt="Riverpod">
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android">
</p>

<p align="center">
  <img src="fastlane/metadata/android/en-US/images/featureGraphic.png" width="720" alt="Frequenza: the dial">
</p>

---

Somewhere, right now, a station in Paraguay is reading the news. A techno
classic is playing in Berlin. Someone in the Loire valley is taking calls.

**Frequenza** puts all of them behind a single dial. One turn, a soft crackle
of static, and you land on a live station somewhere on the planet. The map
draws the route of your trip, tells you how far you travelled and what time
it is over there. Then you turn again.

No account, no ads, no algorithm deciding what you should like. Just the
pleasure of getting lost on the airwaves.

## 📻 On air

<p align="center">
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/1.png" width="270" alt="Landing in France">
  &nbsp;&nbsp;
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/2.png" width="270" alt="A saved station">
</p>

- 🎛️ **The dial.** Every turn is a flight to a random live station, from the free [Radio Browser](https://www.radio-browser.info) directory.
- 🗺️ **The trip.** A dotted world map draws the route from your last stop, with the distance and the local time of the station.
- 🎵 **What's on.** The title of the song on air, when the station sends it.
- ❤️ **Presets.** One tap on the heart keeps a station among your favourites, newest first.
- 🔙 **Back and forth.** Fly back to the previous stop, or on to the next one, also from the notification.
- 🌙 **Pocket radio.** It keeps playing with the screen off, with controls in the notification, on the lock screen and from your headphones.
- 🎨 **Two finishes.** Light or dark, in English or Italian.

## 🧭 How a trip works

```
 Off ──turn──▶ Flying ──the stream really plays──▶ On air ──turn──▶ Flying …
                 │                                     │
                 └── signal lost: retry, then Failed   └── paused · buffering · ended
```

1. **Take-off.** The radio picks a station and the static starts: a soft
   hiss, generated to sound like a dial sweeping across the band.
2. **The flight.** The stream loads in silence. A flight lasts at least a
   moment, even on a fast connection, and retries on its own if the signal
   is lost.
3. **Landing.** Only when the station really plays does the static fade out
   while the station fades in. The map, the distance and the clock follow.

## 🛠️ For developers

Curious about how something works? Just ask me or your LLM :) (I know you are lazy as me, and reading the code is no more an option)

### Tech stack

- **Core:** Flutter 3.38, Dart 3.10
- **State:** Riverpod 2.6 with code generation; Freezed sealed unions
- **Audio:** just_audio, audio_service, audio_session, plus a small native player for the static
- **Navigation:** go_router
- **Translations:** easy_localization (English, Italian)
- **Storage:** shared_preferences

### From commit to store

- **develop:** every merge builds a dev APK and sends it to the testers' Telegram chat.
- **Versions:** a `version:major`, `version:minor` or `version:patch` label on the release pull request bumps the version.
- **main:** every merge builds the signed bundle for the Play Store closed test.
- **Store listing:** texts and images live in `fastlane/metadata/` and are published from a workflow.

## 💬 Ideas and bugs

Found a station that never lands, or dreaming of a feature?
[Open an issue](https://github.com/davidetarsi/frequenza/issues): every report helps.

## 🙏 Credits

- [Radio Browser](https://www.radio-browser.info), the community directory of internet radio stations.
- [Natural Earth](https://www.naturalearthdata.com), public domain map data.
- Every station on the dial, for broadcasting to whoever happens to tune in.

## 📄 License

[TO DECIDE]

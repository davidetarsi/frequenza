import 'package:freezed_annotation/freezed_annotation.dart';

part 'welcome_session.freezed.dart';

/// The copy and target displayed while explaining or leaving the guide.
enum WelcomeStep { radio, favorites, diary }

@freezed
sealed class WelcomeSession with _$WelcomeSession {
  const WelcomeSession._();
  const factory WelcomeSession.radio() = WelcomeRadio;
  const factory WelcomeSession.favorites() = WelcomeFavorites;
  const factory WelcomeSession.diary() = WelcomeDiary;
  const factory WelcomeSession.closing(WelcomeStep step) = WelcomeClosing;
  const factory WelcomeSession.completed(WelcomeStep step) = WelcomeCompleted;

  WelcomeStep get step => switch (this) {
    WelcomeRadio() => WelcomeStep.radio,
    WelcomeFavorites() => WelcomeStep.favorites,
    WelcomeDiary() => WelcomeStep.diary,
    WelcomeClosing(:final step) || WelcomeCompleted(:final step) => step,
  };

  bool get isClosing => this is WelcomeClosing || this is WelcomeCompleted;
}

@freezed
sealed class WelcomeEvent with _$WelcomeEvent {
  const factory WelcomeEvent.advance() = WelcomeAdvanced;
  const factory WelcomeEvent.dismiss() = WelcomeDismissed;
  const factory WelcomeEvent.completionRecorded() = WelcomeCompletionRecorded;
}

/// | From             | Event                | To                         |
/// |------------------|----------------------|----------------------------|
/// | Radio            | Advance              | Favorites (start radio)    |
/// | Favorites        | Advance              | Diary                      |
/// | Diary            | Advance              | Closing(Diary)             |
/// | Radio/Favorites/Diary | Dismiss          | Closing(current step)      |
/// | Closing(step)    | CompletionRecorded   | Completed(step)            |
///
/// Closing records completion once. Completed lets presentation animate the
/// departure and navigate. All other pairs keep the same state, including
/// repeated taps/back presses while closing. No timing or I/O lives here.
WelcomeSession nextWelcome(WelcomeSession session, WelcomeEvent event) =>
    switch ((session, event)) {
      (WelcomeRadio(), WelcomeAdvanced()) => const WelcomeSession.favorites(),
      (WelcomeFavorites(), WelcomeAdvanced()) => const WelcomeSession.diary(),
      (WelcomeDiary(), WelcomeAdvanced()) => const WelcomeSession.closing(
        WelcomeStep.diary,
      ),
      (
        WelcomeRadio() || WelcomeFavorites() || WelcomeDiary(),
        WelcomeDismissed(),
      ) =>
        WelcomeSession.closing(session.step),
      (WelcomeClosing(:final step), WelcomeCompletionRecorded()) =>
        WelcomeSession.completed(step),
      _ => session,
    };

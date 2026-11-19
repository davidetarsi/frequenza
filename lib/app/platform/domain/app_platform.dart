/// The optional capabilities of the host device. Missing information returns
/// neutral values; a failed clipboard write throws instead of claiming success.
abstract interface class AppPlatform {
  String get deviceLanguageCode;
  Future<void> updateNotificationChannel(String id, String name);
  Future<String> appVersion();
  Future<String> deviceDescription();
  Future<int> androidSdk();
  Future<Set<String>> installedPackages(Iterable<String> packages);
  Future<Uri?> notificationArtwork();

  /// Copies and gives haptic feedback. True if the OS displays confirmation.
  Future<bool> copyText(String text);
  Future<bool> openExternal(Uri uri);
}

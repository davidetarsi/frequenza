/// The span of the diary's page.
enum DiaryPeriod {
  week(Duration(days: 7)),
  month(Duration(days: 30)),
  year(Duration(days: 365)),
  always(null);

  const DiaryPeriod(this.length);

  final Duration? length;

  /// The first moment counted, or null for always.
  DateTime? since(DateTime now) => switch (length) {
    final length? => now.subtract(length),
    null => null,
  };
}
